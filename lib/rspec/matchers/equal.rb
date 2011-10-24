module RSpec
  module Matchers
    class Equal
      include BaseMatcher

      def matches?(actual)
        super(actual).equal?(expected)
      end

      def failure_message_for_should
        return <<-MESSAGE

expected #{inspect_object(expected)}
     got #{inspect_object(actual)}

Compared using equal?, which compares object identity,
but expected and actual are not the same object. Use
'actual.should == expected' if you don't care about
object identity in this example.

MESSAGE
      end

      def failure_message_for_should_not
        return <<-MESSAGE

expected not #{inspect_object(actual)}
         got #{inspect_object(expected)}

Compared using equal?, which compares object identity.

MESSAGE
      end

      def diffable?
        true
      end

    private

      def inspect_object(o)
        "#<#{o.class}:#{o.object_id}> => #{o.inspect}"
      end
    end

    # Passes if <tt>actual.equal?(expected)</tt> (object identity).
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # @example
    #
    #   5.should equal(5) # Fixnums are equal
    #   "5".should_not equal("5") # Strings that look the same are not the same object
    def equal(expected)
      Equal.new(expected)
    end
  end
end
