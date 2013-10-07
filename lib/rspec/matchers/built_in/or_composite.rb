module RSpec
  module Matchers
    module BuiltIn
      class OrComposite < Composite

        def matches?(actual)
          base_matcher.matches?(actual) || new_matcher.matches?(actual)
        end

      end
    end
  end
end
