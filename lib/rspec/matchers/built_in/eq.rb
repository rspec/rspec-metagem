module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `eq`.
      # Not intended to be instantiated directly.
      class Eq < BaseMatcher
        # @api private
        # @return [String]
        def failure_message
          "\nexpected: #{format_object(expected)}\n     got: #{format_object(actual)}\n\n(compared using ==)\n"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          "\nexpected: value != #{format_object(expected)}\n     got: #{format_object(actual)}\n\n(compared using ==)\n"
        end

        # @api private
        # @return [String]
        def description
          "#{name_to_sentence} #{@expected.inspect}"
        end

        # @api private
        # @return [Boolean]
        def diffable?
          true
        end

      private

        def match(expected, actual)
          actual == expected
        end

        def format_object(object)
          if Time === object
            format_time(object)
          elsif defined?(DateTime) && DateTime === object
            format_date_time(object)
          elsif defined?(BigDecimal) && BigDecimal === object
            "#{object.to_s 'F'} (#{object.inspect})"
          else
            object.inspect
          end
        end

        TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

        if Time.method_defined?(:nsec)
          def format_time(time)
            time.strftime("#{TIME_FORMAT}.#{"%09d" % time.nsec} %z")
          end
        else # for 1.8.7
          def format_time(time)
            time.strftime("#{TIME_FORMAT}.#{"%06d" % time.usec} %z")
          end
        end

        DATE_TIME_FORMAT = "%a, %d %b %Y %H:%M:%S.%N %z"
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
