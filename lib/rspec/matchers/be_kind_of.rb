module RSpec
  module Matchers
    class BeAKindOf
      include BaseMatcher

      def matches?(actual)
        super(actual).kind_of?(expected)
      end
    end

    # Passes if actual.kind_of?(expected)
    #
    # @example
    #
    #   5.should be_kind_of(Fixnum)
    #   5.should be_kind_of(Numeric)
    #   5.should_not be_kind_of(Float)
    def be_a_kind_of(expected)
      BeAKindOf.new(expected)
    end
    
    alias_method :be_kind_of, :be_a_kind_of
  end
end
