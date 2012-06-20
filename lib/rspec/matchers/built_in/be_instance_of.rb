module RSpec
  module Matchers
    module BuiltIn
      class BeAnInstanceOf
        include BaseMatcher

        def match(expected, actual)
          actual.instance_of? expected
        end
      end
    end
  end
end
