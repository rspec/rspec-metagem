module Spec
  module Matchers
    module DSL
      # See Spec::Matchers
      def define(name, &declarations)
        define_method name do |*expected|
          Spec::Matchers::Matcher.new name, *expected, &declarations
        end
      end
    end
  end
end

Spec::Matchers.extend Spec::Matchers::DSL
