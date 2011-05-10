module RSpec
  module Core
    module Hooks
      include MetadataHashBuilder::WithConfigWarning

      class Hook
        include RSpec::Core::Applicable

        attr_reader :options

        def initialize(options, &block)
          @options = options
          raise "no block given for #{self.class::TYPE} hook" unless block
          @block = block
        end

        def with_conditions_applicable_to?(example_or_group)
          !example_or_group || options.all?(&apply_to?(example_or_group))
        end

        def to_proc
          @block
        end

        def call
          @block.call
        end
      end

      class BeforeHook < Hook
        TYPE = 'before'
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval(&self)
          else
            call
          end
        end
      end

      class AfterHook < Hook
        TYPE = 'after'
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval_with_rescue(&self)
          else
            call
          end
        end
      end

      class AroundHook < Hook
        TYPE = 'around'
        def call(wrapped_example)
          @block.call(wrapped_example)
        end
      end

      class HookCollection < Array
        def with_conditions_applicable_to(example_or_group)
          self.class.new(select {|hook| hook.with_conditions_applicable_to?(example_or_group)})
        end

        def without_conditions_applicable_to(example_or_group)
          self.class.new(reject {|hook| hook.with_conditions_applicable_to?(example_or_group)})
        end
      end

      class BeforeHooks < HookCollection
        def run_all(example_group_instance)
          each {|h| h.run_in(example_group_instance) } unless empty?
        end

        def run_all!(example_group_instance)
          shift.run_in(example_group_instance) until empty?
        end
      end

      class AfterHooks < HookCollection
        def run_all(example_group_instance)
          reverse.each {|h| h.run_in(example_group_instance) } unless empty?
        end

        def run_all!(example_group_instance)
          pop.run_in(example_group_instance) until empty?
        end
      end

      class AroundHooks < HookCollection; end

      def hooks
        @hooks ||= {
          :around => { :each => AroundHooks.new },
          :before => { :each => BeforeHooks.new, :all => BeforeHooks.new, :suite => BeforeHooks.new },
          :after => { :each => AfterHooks.new, :all => AfterHooks.new, :suite => AfterHooks.new }
        }
      end

      def before(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:before][scope] << BeforeHook.new(options, &block)
      end

      def after(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:after][scope] << AfterHook.new(options, &block)
      end

      def around(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:around][scope] << AroundHook.new(options, &block)
      end

      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example_group_instance=nil)
        hooks[hook][scope].run_all(example_group_instance)
      end

      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example_group_instance)
        hooks[hook][scope].run_all!(example_group_instance)
      end

      def run_hook_filtered(hook, scope, group, example_group_instance, example = nil)
        find_hook(hook, scope, group, example).run_all(example_group_instance)
      end

      def find_hook(hook, scope, example_group_class, example = nil)
        found_hooks = hooks[hook][scope].with_conditions_applicable_to(example || example_group_class)

        # ensure we don't re-run :all hooks that were applied to any of the parent groups
        if scope == :all
          super_klass = example_group_class.superclass
          while super_klass != RSpec::Core::ExampleGroup
            found_hooks = found_hooks.without_conditions_applicable_to(super_klass)
            super_klass = super_klass.superclass
          end
        end

        found_hooks
      end

    private

      def scope_and_options_from(*args)
        scope = if [:each, :all, :suite].include?(args.first)
          args.shift
        elsif args.any? { |a| a.is_a?(Symbol) }
          raise ArgumentError.new("You must explicitly give a scope (:each, :all, or :suite) when using symbols as metadata for a hook.")
        else
          :each
        end

        options = build_metadata_hash_from(args)
        return scope, options
      end
    end
  end
end
