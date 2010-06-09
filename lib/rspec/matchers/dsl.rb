module RSpec
  module Matchers
    module DSL
      # See RSpec::Matchers
      def define(name, &declarations)
        define_method name do |*expected|
          $matcher_execution_context = self
          RSpec::Matchers::Matcher.new name, *expected, &declarations
        end
      end

      alias_method :matcher, :define
    end
  end
end

RSpec::Matchers.extend RSpec::Matchers::DSL
