module RSpec
  module Matchers
    module BuiltIn
      class Eq < BaseMatcher
        def match(expected, actual)
          actual == expected
        end

        def failure_message
          "\nexpected: #{format_object(expected)}\n     got: #{format_object(actual)}\n\n(compared using ==)\n"
        end

        def failure_message_when_negated
          "\nexpected: value != #{format_object(expected)}\n     got: #{format_object(actual)}\n\n(compared using ==)\n"
        end

        def description
          "#{name_to_sentence} #{@expected.inspect}"
        end

        def diffable?; true; end

      private

        def format_object(object)
          if Time === object
            format_time(object)
          elsif defined?(DateTime) && DateTime === object
            format_date_time(object)
          else
            object.inspect
          end
        end

        TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
        # Append microseconds to the default format string
        def format_time(time)
          time.strftime("#{TIME_FORMAT}.#{"%06d" % time.usec} %z")
        end

        DATE_TIME_FORMAT = "%a, %d %b %Y %H:%M:%S.%6N %z"
        # ActiveSupport sometimes overrides inspect. If `ActiveSupport` is
        # defined use a custom format string that includes more time precision.
        def format_date_time(date_time)
          if defined?(ActiveSupport)
            date_time.strftime(DATE_TIME_FORMAT)
          else
            date_time.inspect
          end
        end
      end
    end
  end
end

