module RSpec
  module Core
    module Formatters
      # Formatters helpers
      module Helpers
        # @private
        SUB_SECOND_PRECISION = 5

        # @private
        DEFAULT_PRECISION = 2

        # @api private
        #
        # Formats seconds into a human-readable string.
        #
        # @param duration [Float, Fixnum] in seconds
        # @return [String] human-readable time
        #
        # @example
        #    format_duration(1) #=>  "1 minute 1 second"
        #    format_duration(135.14) #=> "2 minutes 15.14 seconds"
        def self.format_duration(duration)
          precision = case
                      when duration < 1 then    SUB_SECOND_PRECISION
                      when duration < 120 then  DEFAULT_PRECISION
                      when duration < 300 then  1
                      else                  0
                      end

          if duration > 60
            minutes = (duration.to_i / 60).to_i
            seconds = duration - minutes * 60

            "#{pluralize(minutes, 'minute')} #{pluralize(format_seconds(seconds, precision), 'second')}"
          else
            pluralize(format_seconds(duration, precision), 'second')
          end
        end

        # @api private
        #
        # Formats seconds to have 5 digits of precision with trailing zeros removed if the number
        # is less than 1 or with 2 digits of precision if the number is greater than zero.
        #
        # @param float [Float]
        # @return [String] formatted float
        #
        # @example
        #    format_seconds(0.000006) #=> "0.00001"
        #    format_seconds(0.020000) #=> "0.02"
        #    format_seconds(1.00000000001) #=> "1"
        #
        # The precision used is set in {Helpers::SUB_SECOND_PRECISION} and {Helpers::DEFAULT_PRECISION}.
        #
        # @see #strip_trailing_zeroes
        def self.format_seconds(float, precision=nil)
          precision ||= (float < 1) ? SUB_SECOND_PRECISION : DEFAULT_PRECISION
          formatted = "%.#{precision}f" % float
          strip_trailing_zeroes(formatted)
        end

        # @api private
        #
        # Remove trailing zeros from a string.
        #
        # @param string [String] string with trailing zeros
        # @return [String] string with trailing zeros removed
        def self.strip_trailing_zeroes(string)
          stripped = string.sub(/[^1-9]+$/, '')
          stripped.empty? ? "0" : stripped
        end
        private_class_method :strip_trailing_zeroes

        # @api private
        #
        # Pluralize a word based on a count.
        #
        # @param count [Fixnum] number of objects
        # @param string [String] word to be pluralized
        # @return [String] pluralized word
        def self.pluralize(count, string)
          "#{count} #{string}#{'s' unless count.to_f == 1}"
        end
      end
    end
  end
end
