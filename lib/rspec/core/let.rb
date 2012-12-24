module RSpec
  module Core
    module Let

      # @api private
      #
      # Gets the LetDefinitions module. The module is mixed into
      # the example group and is used to hold all let definitions.
      # This is done so that the block passed to `let` can be
      # forwarded directly on to `define_method`, so that all method
      # constructs (including `super` and `return`) can be used in
      # a `let` block.
      #
      # The memoization is provided by a method definition on the
      # example group that supers to the LetDefinitions definition
      # in order to get the value to memoize.
      def self.module_for(example_group)
        get_constant_or_yield(example_group, :LetDefinitions) do
          # Expose `define_method` as a public method, so we can
          # easily use it below.
          mod = Module.new { public_class_method :define_method }
          example_group.__send__(:include, mod)
          example_group.const_set(:LetDefinitions, mod)
          mod
        end
      end

      if Module.method(:const_defined?).arity == 1 # for 1.8
        # @api private
        #
        # Gets the named constant or yields.
        # On 1.8, const_defined? / const_get do not take into
        # account the inheritance hierarchy.
        def self.get_constant_or_yield(example_group, name)
          if example_group.const_defined?(name)
            example_group.const_get(name)
          else
            yield
          end
        end
      else
        # @api private
        #
        # Gets the named constant or yields.
        # On 1.9, const_defined? / const_get take into account the
        # the inheritance by default, and accept an argument to
        # disable this behavior. It's important that we don't
        # consider inheritance here; each example group level that
        # uses a `let` should get its own `LetDefinitions` module.
        def self.get_constant_or_yield(example_group, name)
          if example_group.const_defined?(name, (check_ancestors = false))
            example_group.const_get(name, (check_ancestors = false))
          else
            yield
          end
        end
      end

      module ExampleGroupMethods
        # Generates a method whose return value is memoized after the first
        # call. Useful for reducing duplication between examples that assign
        # values to the same local variable.
        #
        # @note `let` _can_ enhance readability when used sparingly (1,2, or
        #   maybe 3 declarations) in any given example group, but that can
        #   quickly degrade with overuse. YMMV.
        #
        # @note `let` uses an `||=` conditional that has the potential to
        #   behave in surprising ways in examples that spawn separate threads,
        #   though we have yet to see this in practice. You've been warned.
        #
        # @example
        #
        #   describe Thing do
        #     let(:thing) { Thing.new }
        #
        #     it "does something" do
        #       # first invocation, executes block, memoizes and returns result
        #       thing.do_something
        #
        #       # second invocation, returns the memoized value
        #       thing.should be_something
        #     end
        #   end
        def let(name, &block)
          # We have to pass the block directly to `define_method` to
          # allow it to use method constructs like `super` and `return`.
          ::RSpec::Core::Let.module_for(self).define_method(name, &block)

          # Apply the memoization. The method has been defined in an ancestor
          # module so we can use `super` here to get the value.
          define_method(name) do
            __memoized.fetch(name) { |k| __memoized[k] = super() }
          end
        end

        # Just like `let`, except the block is invoked by an implicit `before`
        # hook. This serves a dual purpose of setting up state and providing a
        # memoized reference to that state.
        #
        # @example
        #
        #   class Thing
        #     def self.count
        #       @count ||= 0
        #     end
        #
        #     def self.count=(val)
        #       @count += val
        #     end
        #
        #     def self.reset_count
        #       @count = 0
        #     end
        #
        #     def initialize
        #       self.class.count += 1
        #     end
        #   end
        #
        #   describe Thing do
        #     after(:each) { Thing.reset_count }
        #
        #     context "using let" do
        #       let(:thing) { Thing.new }
        #
        #       it "is not invoked implicitly" do
        #         Thing.count.should eq(0)
        #       end
        #
        #       it "can be invoked explicitly" do
        #         thing
        #         Thing.count.should eq(1)
        #       end
        #     end
        #
        #     context "using let!" do
        #       let!(:thing) { Thing.new }
        #
        #       it "is invoked implicitly" do
        #         Thing.count.should eq(1)
        #       end
        #
        #       it "returns memoized version on first invocation" do
        #         thing
        #         Thing.count.should eq(1)
        #       end
        #     end
        #   end
        def let!(name, &block)
          let(name, &block)
          before { __send__(name) }
        end
      end

      # @private
      def __memoized
        @__memoized ||= {}
      end

      def self.included(mod)
        mod.extend ExampleGroupMethods
      end
    end
  end
end
