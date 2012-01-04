module RSpec
  module Matchers
    module DSL
      # Defines a custom matcher.
      # @see RSpec::Matchers
      def define(name, &declarations)
        matcher = RSpec::Matchers::Matcher.new(name, &declarations)
        define_method name do |*expected|
          $matcher_execution_context = self
          matcher.for_expected(*expected)
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
