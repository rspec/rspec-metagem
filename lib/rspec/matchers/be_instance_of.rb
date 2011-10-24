module RSpec
  module Matchers
    class BeAnInstanceOf
      include BaseMatcher

      def matches?(actual)
        super(actual).instance_of?(expected)
      end
    end

    # Passes if actual.instance_of?(expected)
    #
    # @example
    #
    #   5.should be_instance_of(Fixnum)
    #   5.should_not be_instance_of(Numeric)
    #   5.should_not be_instance_of(Float)
    def be_an_instance_of(expected)
      BeAnInstanceOf.new(expected)
    end
    
    alias_method :be_instance_of, :be_an_instance_of
  end
end
