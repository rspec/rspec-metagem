module RSpec
  module Core
    module Formatters
      class DeprecationFormatter < Struct.new(:deprecation_stream, :summary_stream)
        attr_reader :count

        def initialize(*_)
          super
          @count = 0
        end

        def printer
          @printer ||= File === deprecation_stream ?
            FilePrinter.new(deprecation_stream, summary_stream, self) :
            IOPrinter.new(deprecation_stream, summary_stream, self)
        end

        def deprecation(data)
          @count += 1

          if data[:message]
            deprecation_stream.print data[:message]
          else
            printer.print_deprecation_message data
          end
        end

        def deprecation_summary
          printer.deprecation_summary
        end

        module DeprecationMessage
          def deprecation_message(data)
            msg =  "#{data[:deprecated]} is deprecated."
            msg << " Use #{data[:replacement]} instead." if data[:replacement]
            msg << " Called from #{data[:call_site]}." if data[:call_site]
            msg
          end
        end

        class FilePrinter < Struct.new(:deprecation_stream, :summary_stream, :counter)
          include DeprecationMessage

          def print_deprecation_message(data)
            deprecation_stream.puts deprecation_message(data)
          end

          def deprecation_summary
            if counter.count > 0
              summary_stream.print "\n#{counter.count} deprecation"
              summary_stream.print "s" if counter.count > 1
              summary_stream.print " logged to "
              summary_stream.puts deprecation_stream.path
            end
          end
        end

        class IOPrinter < Struct.new(:deprecation_stream, :summary_stream, :counter)
          include DeprecationMessage

          def initialize(*_)
            super
            @seen_deprecations = Hash.new { 0 }
            @deprecation_messages = Hash.new { |h, k| h[k] = [] }
          end

          def print_deprecation_message(data)
            @seen_deprecations[data[:deprecated]] += 1

            if @seen_deprecations[data[:deprecated]] <= 3
              @deprecation_messages[data[:deprecated]] << deprecation_message(data)
            elsif @seen_deprecations[data[:deprecated]] == 4
              msg  = "Too many uses of deprecated '#{data[:deprecated]}'."
              msg << " Set config.deprecation_stream to a File for full output"
              @deprecation_messages[data[:deprecated]] << msg
            end
          end

          def deprecation_summary
            messages = @deprecation_messages.values.flatten
            return unless messages.size > 0

            deprecation_stream.puts "\nDeprecation Warnings:\n\n"
            messages.each do |msg|
              deprecation_stream.puts msg
            end

            summary_stream.puts "\n#{counter.count} deprecation warning#{counter.count > 1 ? 's' : ''} total"
          end
        end

      end
    end
  end
end
