module RSpec
  module Matchers
    class Configuration
      def initialize
        @original_should = ::Kernel.instance_method(:should)
        @original_should_not = ::Kernel.instance_method(:should_not)
        @original_expect = RSpec::Matchers.instance_method(:expect)
      end

      def syntax=(values)
        if Array(values).include?(:expect)
          enable_expect_syntax
        else
          disable_expect_syntax
        end

        if Array(values).include?(:should)
          enable_should_syntax
        else
          disable_should_syntax
        end
      end

      def syntax
        syntaxes = []
        syntaxes << :should if ::Kernel.method_defined?(:should)
        syntaxes << :expect if RSpec::Matchers.method_defined?(:expect)
        syntaxes
      end

    private

      def disable_should_syntax
        ::Kernel.module_eval do
          return unless method_defined?(:should)
          undef should
          undef should_not
        end
      end

      def enable_should_syntax
        should, should_not = @original_should, @original_should_not

        ::Kernel.module_eval do
          define_method(:should) do |*args, &block|
            should.bind(self).call(*args, &block)
          end

          define_method(:should_not) do |*args, &block|
            should_not.bind(self).call(*args, &block)
          end
        end
      end

      def disable_expect_syntax
        RSpec::Matchers.module_eval do
          return unless method_defined?(:expect)
          undef expect
        end
      end

      def enable_expect_syntax
        expect = @original_expect

        RSpec::Matchers.module_eval do
          define_method(:expect) do |*args, &block|
            expect.bind(self).call(*args, &block)
          end
        end
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end
  end
end

