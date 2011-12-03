module RSpec
  module Core
    module Hooks
      include MetadataHashBuilder::WithConfigWarning

      class Hook
        attr_reader :options

        def initialize(options, &block)
          @options = options
          raise "no block given for #{display_name}" unless block
          @block = block
        end

        def options_apply?(example_or_group)
          example_or_group.all_apply?(options)
        end

        def to_proc
          @block
        end

        def call
          @block.call
        end

        def display_name
          self.class.name.split('::').last.gsub('Hook','').downcase << " hook"
        end
      end

      class BeforeHook < Hook
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval(&self)
          else
            call
          end
        end
      end

      class AfterHook < Hook
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval_with_rescue(&self)
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
        def find_hooks_for(example_or_group)
          self.class.new(select {|hook| hook.options_apply?(example_or_group)})
        end

        def without_hooks_for(example_or_group)
          self.class.new(reject {|hook| hook.options_apply?(example_or_group)})
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
          reverse.each {|h| h.run_in(example_group_instance) }
        end

        def run_all!(example_group_instance)
          pop.run_in(example_group_instance) until empty?
        end
      end

      class AroundHooks < HookCollection; end

      # @private
      def hooks
        @hooks ||= {
          :around => { :each => AroundHooks.new },
          :before => { :each => BeforeHooks.new, :all => BeforeHooks.new, :suite => BeforeHooks.new },
          :after => { :each => AfterHooks.new, :all => AfterHooks.new, :suite => AfterHooks.new }
        }
      end

      # @api public
      # @overload before(&block)
      # @overload before(scope, &block)
      # @overload before(scope, conditions, &block)
      # @overload before(conditions, &block)
      #
      # @param [Symbol] scope `:each`, `:all`, or `:suite` (defaults to `:each`)
      # @param [Hash] conditions
      #   constrains this hook to examples matching these conditions e.g.
      #   `before(:each, :ui => true) { ... }` will only run with examples or
      #   groups declared with `:ui => true`.
      #
      # @see #after
      # @see #around
      # @see ExampleGroup
      # @see SharedContext
      # @see SharedExampleGroup
      # @see Configuration
      #
      # Declare a block of code to be run before each example (using `:each`)
      # or once before any example (using `:all`). These are usually declared
      # directly in the [ExampleGroup](ExampleGroup) to which they apply, but
      # they can also be shared across multiple groups.
      #
      # You can also use `before(:suite)` to run a block of code before any
      # example groups are run. This should be declared in
      # [RSpec.configure](../../RSpec#configure-class_method)
      #
      # Instance variables declared in `before(:each)` or `before(:all)` are
      # accessible within each example.
      #
      # ### Order
      #
      # `before` hooks are stored in three scopes, which are run in order:
      # `:suite`, `:all`, and `:each`. They can also be declared in several
      # different places: `RSpec.configure`, a parent group, the current group.
      # They are run in the following order:
      #
      #     before(:suite) # declared in RSpec.configure
      #     before(:all)   # declared in RSpec.configure
      #     before(:all)   # declared in a parent group
      #     before(:all)   # declared in the current group
      #     before(:each)  # declared in RSpec.configure
      #     before(:each)  # declared in a parent group
      #     before(:each)  # declared in the current group
      #
      # If more than one `before` is declared within any one scope, they are run
      # in the order in which they are declared.
      #
      # ### Conditions
      #
      # When you add a conditions hash to `before(:each)` or `before(:all)`,
      # RSpec will only apply that hook to groups or examples that match the
      # conditions. e.g.
      #
      #     RSpec.configure do |config|
      #       config.before(:each, :authorized => true) do
      #         log_in_as :authorized_user
      #       end
      #     end
      #
      #     describe Something, :authorized => true do
      #       # the before hook will run in before each example in this group
      #     end
      #
      #     describe SomethingElse do
      #       it "does something", :authorized => true do
      #         # the before hook will run before this example
      #       end
      #
      #       it "does something else" do
      #         # the hook will not run before this example
      #       end
      #     end
      #
      # ### Warning: `before(:suite, :with => :conditions)`
      #
      # The conditions hash is used to match against specific examples. Since
      # `before(:suite)` is not run in relation to any specific example or
      # group, conditions passed along with `:suite` are effectively ignored.
      #
      # ### Exceptions
      #
      # When an exception is raised in a `before` block, RSpec skips any
      # subsequent `before` blocks and the example, but runs all of the
      # `after(:each)` and `after(:all)` hooks.
      #
      # ### Warning: implicit before blocks
      #
      # `before` hooks can also be declared in shared contexts which get
      # included implicitly either by you or by extension libraries. Since
      # RSpec runs these in the order in which they are declared within each
      # scope, load order matters, and can lead to confusing results when one
      # before block depends on state that is prepared in another before block
      # that gets run later.
      #
      # ### Warning: `before(:all)`
      #
      # It is very tempting to use `before(:all)` to speed things up, but we
      # recommend that you avoid this as there are a number of gotchas, as well
      # as things that simply don't work.
      #
      # #### context
      #
      # `before(:all)` is run in an example that is generated to provide group
      # context for the block.
      #
      # #### instance variables
      #
      # Instance variables declared in `before(:all)` are shared across all the
      # examples in the group.  This means that each example can change the
      # state of a shared object, resulting in an ordering dependency that can
      # make it difficult to reason about failures.
      #
      # ### other frameworks
      #
      # Mock object frameworks and database transaction managers (like
      # ActiveRecord) are typically designed around the idea of setting up
      # before an example, running that one example, and then tearing down.
      # This means that mocks and stubs can (sometimes) be declared in
      # `before(:all)`, but get torn down before the first real example is ever
      # run.
      #
      # You _can_ create database-backed model objects in a `before(:all)` in
      # rspec-rails, but it will not be wrapped in a transaction for you, so
      # you are on your own to clean up in an `after(:all)` block.
      #
      # @example before(:each) declared in an [ExampleGroup](ExampleGroup)
      #
      #     describe Thing do
      #       before(:each) do
      #         @thing = Thing.new
      #       end
      #
      #       it "does something" do
      #         # here you can access @thing
      #       end
      #     end
      #
      # @example before(:all) declared in an [ExampleGroup](ExampleGroup)
      #
      #     describe Parser do
      #       before(:all) do
      #         File.open(file_to_parse, 'w') do |f|
      #           f.write <<-CONTENT
      #             stuff in the file
      #           CONTENT
      #         end
      #       end
      #
      #       it "parses the file" do
      #         Parser.parse(file_to_parse)
      #       end
      #
      #       after(:all) do
      #         File.delete(file_to_parse)
      #       end
      #     end
      def before(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:before][scope] << BeforeHook.new(options, &block)
      end

      # @api public
      # @overload after(&block)
      # @overload after(scope, &block)
      # @overload after(scope, conditions, &block)
      # @overload after(conditions, &block)
      #
      # @param [Symbol] scope `:each`, `:all`, or `:suite` (defaults to `:each`)
      # @param [Hash] conditions
      #   constrains this hook to examples matching these conditions e.g.
      #   `after(:each, :ui => true) { ... }` will only run with examples or
      #   groups declared with `:ui => true`.
      #
      # @see #before
      # @see #around
      # @see ExampleGroup
      # @see SharedContext
      # @see SharedExampleGroup
      # @see Configuration
      #
      # Declare a block of code to be run after each example (using `:each`) or
      # once after all examples (using `:all`). See
      # [#before](Hooks#before-instance_method) for more information about
      # ordering.
      #
      # ### Exceptions
      #
      # `after` hooks are guaranteed to run even when there are exceptions in
      # `before` hooks or examples.  When an exception is raised in an after
      # block, the exception is captured for later reporting, and subsequent
      # `after` blocks are run.
      #
      # ### Order
      #
      # `after` hooks are stored in three scopes, which are run in order:
      # `:each`, `:all`, and `:suite`. They can also be declared in several
      # different places: `RSpec.configure`, a parent group, the current group.
      # They are run in the following order:
      #
      #     after(:each) # declared in the current group
      #     after(:each) # declared in a parent group
      #     after(:each) # declared in RSpec.configure
      #     after(:all)  # declared in the current group
      #     after(:all)  # declared in a parent group
      #     after(:all)  # declared in RSpec.configure
      #
      # This is the reverse of the order in which `before` hooks are run.
      # Similarly, if more than one `after` is declared within any one scope,
      # they are run in reverse order of that in which they are declared.
      def after(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:after][scope] << AfterHook.new(options, &block)
      end

      # @api public
      # @overload around(&block)
      # @overload around(scope, &block)
      # @overload around(scope, conditions, &block)
      # @overload around(conditions, &block)
      #
      # @param [Symbol] scope `:each` (defaults to `:each`)
      #   present for syntax parity with `before` and `after`, but `:each` is
      #   the only supported value.
      #
      # @param [Hash] conditions
      #   constrains this hook to examples matching these conditions e.g.
      #   `around(:each, :ui => true) { ... }` will only run with examples or
      #   groups declared with `:ui => true`.
      #
      # @yield [Example] the example to run
      #
      # @note the syntax of `around` is similar to that of `before` and `after`
      #   but the semantics are quite different. `before` and `after` hooks are
      #   run in the context of of the examples with which they are associated,
      #   whereas `around` hooks are actually responsible for running the
      #   examples. Consequently, `around` hooks do not have direct access to
      #   resources that are made available within the examples and their
      #   associated `before` and `after` hooks.
      #
      # @note `:each` is the only supported scope.
      #
      # Declare a block of code, parts of which will be run before and parts
      # after the example. It is your responsibility to run the example:
      #
      #     around(:each) do |ex|
      #       # do some stuff before
      #       ex.run
      #       # do some stuff after
      #     end
      #
      # The yielded example aliases `run` with `call`, which lets you treat it
      # like a `Proc`.  This is especially handy when working with libaries
      # that manage their own setup and teardown using a block or proc syntax,
      # e.g.
      #
      #     around(:each) {|ex| Database.transaction(&ex)}
      #     around(:each) {|ex| FakeFS(&ex)}
      #
      def around(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:around][scope] << AroundHook.new(options, &block)
      end

      # @private
      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example_group_instance=nil)
        hooks[hook][scope].run_all(example_group_instance)
      end

      # @private
      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example_group_instance)
        hooks[hook][scope].run_all!(example_group_instance)
      end

      # @private
      def run_hook_filtered(hook, scope, group, example_group_instance, example = nil)
        find_hook(hook, scope, group, example).run_all(example_group_instance)
      end

      # @private
      def find_hook(hook, scope, example_group_class, example = nil)
        found_hooks = hooks[hook][scope].find_hooks_for(example || example_group_class)

        # ensure we don't re-run :all hooks that were applied to any of the parent groups
        if scope == :all
          super_klass = example_group_class.superclass
          while super_klass != RSpec::Core::ExampleGroup
            found_hooks = found_hooks.without_hooks_for(super_klass)
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
