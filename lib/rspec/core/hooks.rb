module RSpec
  module Core
    module Hooks

      class Hook
        attr_reader :options

        def initialize(options, block)
          @options = options
          @block = block
        end

        def options_apply?(group)
          !group || group.all_apply?(options)
        end

        def to_proc
          @block
        end

        def call
          @block.call
        end
      end

      class BeforeHook < Hook
        def run_in(example)
          example ? example.instance_eval(&self) : call
        end
      end

      class AfterHook < Hook
        def run_in(example)
          if example
            begin
              example.instance_eval(&self)
            rescue Exception => e
              if example.respond_to?(:example)
                example.example.set_exception(e)
              end
            end
          else
            call
          end
        end
      end

      class AroundHook < Hook
        def call(wrapped_example)
          @block.call(wrapped_example)
        end
      end

      class HookCollection < Array
        def find_hooks_for(group)
          dup.reject {|hook| !hook.options_apply?(group)}
        end
      end

      class BeforeHooks < HookCollection
        def run_all(example)
          each {|h| h.run_in(example) }
        end

        def run_all!(example)
          shift.run_in(example) until empty?
        end
      end

      class AfterHooks < HookCollection
        def run_all(example)
          reverse.each {|h| h.run_in(example) }
        end

        def run_all!(example)
          pop.run_in(example) until empty?
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

      def before(scope=:each, options={}, &block)
        hooks[:before][scope] << BeforeHook.new(options, block)
      end

      def after(scope=:each, options={}, &block)
        hooks[:after][scope] << AfterHook.new(options, block)
      end

      def around(scope=:each, options={}, &block)
        hooks[:around][scope] << AroundHook.new(options, block)
      end

      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example=nil)
        hooks[hook][scope].run_all(example)
      end

      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example)
        hooks[hook][scope].run_all!(example)
      end

      def run_hook_filtered(hook, scope, group, example)
        find_hook(hook, scope, group).run_all(example)
      end

      def find_hook(hook, scope, group)
        hooks[hook][scope].find_hooks_for(group)
      end
    end
  end
end
