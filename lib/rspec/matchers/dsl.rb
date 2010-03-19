module Rspec
  module Matchers
    module DSL
      # See Rspec::Matchers
      def define(name, &declarations)
        define_method name do |*expected|
          $matcher_execution_context = self
          Rspec::Matchers::Matcher.new name, *expected, &declarations
        end
      end
    end
  end
end

Rspec::Matchers.extend Rspec::Matchers::DSL
