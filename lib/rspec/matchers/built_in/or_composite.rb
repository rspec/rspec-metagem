module RSpec
  module Matchers
    module BuiltIn
      class OrComposite < Composite

        def matches?(actual)
          matchers.any? do |matcher|
            evaluated_matchers << matcher
            matcher.matches? actual
          end
        end

      end
    end
  end
end
