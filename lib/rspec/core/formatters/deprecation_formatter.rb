module RSpec
  module Core
    module Formatters
      class DeprecationFormatter
        def initialize(deprecation_stream=$stderr, summary_stream=$stdout)
          @deprecation_stream = deprecation_stream
          @summary_stream = summary_stream
          @count = 0
        end

        def deprecation(data)
          @count += 1
          if data[:message]
            @deprecation_stream.print data[:message]
          else
            @deprecation_stream.print "DEPRECATION: " unless File === @deprecation_stream
            @deprecation_stream.print "#{data[:method]} is deprecated."
            @deprecation_stream.print " Use #{data[:alternate_method]} instead." if data[:alternate_method]
            @deprecation_stream.print " Called from #{data[:called_from]}." if data[:called_from]
            @deprecation_stream.puts
          end
        end

        def deprecation_summary
          if @count > 0 && File === @deprecation_stream
            @summary_stream.print "\n#{@count} deprecation"
            @summary_stream.print "s" if @count > 1
            @summary_stream.print " logged to "
            @summary_stream.puts File === @deprecation_stream ? @deprecation_stream.path : @deprecation_stream.inspect
          end
        end
      end
    end
  end
end
