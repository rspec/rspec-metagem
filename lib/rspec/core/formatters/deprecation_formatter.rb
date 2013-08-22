require 'rspec/core/formatters/helpers'

module RSpec
  module Core
    module Formatters
      class DeprecationFormatter
        attr_reader :count, :deprecation_stream, :summary_stream

        def initialize(deprecation_stream, summary_stream)
          @deprecation_stream = deprecation_stream
          @summary_stream = summary_stream
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
          def deprecation_message_for(data)
            msg =  "#{data[:deprecated]} is deprecated."
            msg << " Use #{data[:replacement]} instead." if data[:replacement]
            msg << " Called from #{data[:call_site]}." if data[:call_site]
            msg
          end
        end

        class FilePrinter
          include ::RSpec::Core::Formatters::Helpers
          include DeprecationMessage

          attr_reader :deprecation_stream, :summary_stream, :counter

          def initialize(deprecation_stream, summary_stream, counter)
            @deprecation_stream = deprecation_stream
            @summary_stream = summary_stream
            @counter = counter
          end

          def print_deprecation_message(data)
            deprecation_stream.puts deprecation_message_for(data)
          end

          def deprecation_summary
            if counter.count > 0
              summary_stream.puts "\n#{pluralize(counter.count, 'deprecation')} logged to #{deprecation_stream.path}"
            end
          end
        end

        class IOPrinter
          TOO_MANY_USES_LIMIT = 4

          include ::RSpec::Core::Formatters::Helpers
          include DeprecationMessage

          attr_reader :deprecation_stream, :summary_stream, :counter

          def initialize(deprecation_stream, summary_stream, counter)
            @deprecation_stream = deprecation_stream
            @summary_stream = summary_stream
            @counter = counter
            @seen_deprecations = Hash.new { 0 }
            @deprecation_messages = Hash.new { |h, k| h[k] = [] }
          end

          def print_deprecation_message(data)
            deprecation_type = data[:deprecated]
            @seen_deprecations[deprecation_type] += 1

            stash_deprecation_message(deprecation_type, data)
          end

          def stash_deprecation_message(deprecation_type, data)
            if @seen_deprecations[deprecation_type] < TOO_MANY_USES_LIMIT
              @deprecation_messages[deprecation_type] << deprecation_message_for(data)
            elsif @seen_deprecations[deprecation_type] == TOO_MANY_USES_LIMIT
              msg = "Too many uses of deprecated '#{deprecation_type}'."
              msg << " Set config.deprecation_stream to a File for full output."
              @deprecation_messages[deprecation_type] << msg
            end
          end

          def deprecation_summary
            messages = @deprecation_messages.values.flatten
            return unless messages.any?

            print_deferred_deprecation_warnings(messages)

            summary_stream.puts "\n#{pluralize(counter.count, 'deprecation warning')} total"
          end

          def print_deferred_deprecation_warnings(messages)
            deprecation_stream.puts "\nDeprecation Warnings:\n\n"
            messages.each do |msg|
              deprecation_stream.puts msg
            end
          end
        end

      end
    end
  end
end
