module RSpec
  module Matchers
    module DSL
      # Defines a custom matcher.
      # @see RSpec::Matchers
      def define(name, &declarations)
        matcher = RSpec::Matchers::DSL::Matcher.new(name, &declarations)
        define_method name do |*expected|
          matcher.for_expected(*expected).tap { |m| m.matcher_execution_context = @matcher_execution_context || self }
        end
      end

      alias_method :matcher, :define

      if RSpec.respond_to?(:configure)
        RSpec.configure {|c| c.extend self}
      end
    end
  end
end

RSpec::Matchers.extend RSpec::Matchers::DSL
