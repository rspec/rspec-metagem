module RSpec
  module Matchers
    module BuiltIn
      class BeAnInstanceOf
        include BaseMatcher

        def matches?(actual)
          super(actual).instance_of?(expected)
        end
      end
    end
  end
end
