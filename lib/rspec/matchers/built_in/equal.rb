module RSpec
  module Matchers
    module BuiltIn
      class Equal < BaseMatcher
        def match(expected, actual)
          actual.equal? expected
        end

        def failure_message_for_should
          @diffable = false
          case expected
          when FalseClass
            builtin_singleton_message("false")
          when TrueClass
            builtin_singleton_message("true")
          when NilClass
            builtin_singleton_message("nil")
          else
            @diffable = true
            arbitrary_object_message
          end
        end

        def failure_message_for_should_not
          return <<-MESSAGE

expected not #{inspect_object(actual)}
         got #{inspect_object(expected)}

Compared using equal?, which compares object identity.

MESSAGE
        end

        def diffable?
          @diffable
        end

        private

        def builtin_singleton_message(type)
          "\nexpected #{type}\n     got #{inspect_object(actual)}\n"
        end

        def arbitrary_object_message
          return <<-MESSAGE

expected #{inspect_object(expected)}
     got #{inspect_object(actual)}

Compared using equal?, which compares object identity,
but expected and actual are not the same object. Use
`#{eq_expression}` if you don't care about
object identity in this example.

MESSAGE
        end


        def inspect_object(o)
          "#<#{o.class}:#{o.object_id}> => #{o.inspect}"
        end

        def eq_expression
          Expectations::Syntax.positive_expression("actual", "eq(expected)")
        end
      end
    end
  end
end
