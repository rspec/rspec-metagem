module RSpec
  module Core
    module Formatters
      class DeprecationFormatter
        def initialize(deprecation_stream=$stderr, summary_stream=$stdout)
          @deprecation_stream = deprecation_stream
          @summary_stream = summary_stream
          @count = 0
          @seen_deprecations = Hash.new { |h, k| h[k] = 0 }
        end

        def deprecation(data)
          @count += 1
          @seen_deprecations[data[:deprecated]] += 1

          if data[:message]
            @deprecation_stream.print data[:message]
          elsif show_deprecations? data[:deprecated]
            @deprecation_stream.print "DEPRECATION: " unless File === @deprecation_stream
            @deprecation_stream.print "#{data[:deprecated]} is deprecated."
            @deprecation_stream.print " Use #{data[:replacement]} instead." if data[:replacement]
            @deprecation_stream.print " Called from #{data[:call_site]}." if data[:call_site]
            @deprecation_stream.puts
          elsif show_too_many_deprecations? data[:deprecated]
            @deprecation_stream.print "DEPRECATION: Too many uses of deprecated '#{data[:deprecated]}'."
            @deprecation_stream.puts  " Set config.deprecation_stream to a File for full output"
          end
        end

        def deprecation_summary
          if @count > 0 && File === @deprecation_stream
            @summary_stream.print "\n#{@count} deprecation"
            @summary_stream.print "s" if @count > 1
            @summary_stream.print " logged to "
            @summary_stream.puts @deprecation_stream.path
          end
        end

        private

        def show_deprecations?(deprecated)
          @seen_deprecations[deprecated] <= 3 || File === @deprecation_stream
        end

        def show_too_many_deprecations?(deprecated)
          @seen_deprecations[deprecated] == 4
        end
      end
    end
  end
end
