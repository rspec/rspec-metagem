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
          printer.print_deprecation_message data
        end

        def deprecation_summary
          printer.deprecation_summary
        end

        def deprecation_message_for(data)
          if data[:message]
            SpecifiedDeprecationMessage.new(data)
          else
            GeneratedDeprecationMessage.new(data)
          end
        end

        DeprecationMessage = Struct.new(:type) do
          def deprecation_string_for(data)
            return data[:message] if data[:message]
            msg =  "#{data[:deprecated]} is deprecated."
            msg << " Use #{data[:replacement]} instead." if data[:replacement]
            msg << " Called from #{data[:call_site]}." if data[:call_site]
            msg
          end
        end

        class SpecifiedDeprecationMessage < DeprecationMessage
          def initialize(data)
            @message = data[:message]
            super deprecation_type_for(data)
          end

          def to_s
            @message
          end

          def too_many_warnings_message
            msg = "Too many similar deprecation messages reported, disregarding further reports."
            msg << " Set config.deprecation_stream to a File for full output."
            msg
          end

          private

          def deprecation_type_for(data)
            data[:message].gsub(/(\w+\/)+\w+\.rb:\d+/, '')
          end
        end

        class GeneratedDeprecationMessage < DeprecationMessage
          def initialize(data)
            @data = data
            super data[:deprecated]
          end

          def to_s
            deprecation_string_for @data
          end

          def too_many_warnings_message
            msg = "Too many uses of deprecated '#{type}'."
            msg << " Set config.deprecation_stream to a File for full output."
            msg
          end
        end

        class FilePrinter
          include ::RSpec::Core::Formatters::Helpers

          attr_reader :deprecation_stream, :summary_stream, :deprecation_formatter

          def initialize(deprecation_stream, summary_stream, deprecation_formatter)
            @deprecation_stream = deprecation_stream
            @summary_stream = summary_stream
            @deprecation_formatter = deprecation_formatter
          end

          def print_deprecation_message(data)
            deprecation_message = deprecation_formatter.deprecation_message_for(data)
            deprecation_stream.puts deprecation_message.to_s
          end

          def deprecation_summary
            if deprecation_formatter.count > 0
              summary_stream.puts "\n#{pluralize(deprecation_formatter.count, 'deprecation')} logged to #{deprecation_stream.path}"
            end
          end
        end

        class IOPrinter
          TOO_MANY_USES_LIMIT = 4

          include ::RSpec::Core::Formatters::Helpers

          attr_reader :deprecation_stream, :summary_stream, :deprecation_formatter

          def initialize(deprecation_stream, summary_stream, deprecation_formatter)
            @deprecation_stream = deprecation_stream
            @summary_stream = summary_stream
            @deprecation_formatter = deprecation_formatter
            @seen_deprecations = Hash.new { 0 }
            @deprecation_messages = Hash.new { |h, k| h[k] = [] }
          end

          def print_deprecation_message(data)
            deprecation_message = deprecation_formatter.deprecation_message_for(data)
            @seen_deprecations[deprecation_message] += 1

            stash_deprecation_message(deprecation_message)
          end

          def stash_deprecation_message(deprecation_message)
            if @seen_deprecations[deprecation_message] < TOO_MANY_USES_LIMIT
              @deprecation_messages[deprecation_message] << deprecation_message.to_s
            elsif @seen_deprecations[deprecation_message] == TOO_MANY_USES_LIMIT
              @deprecation_messages[deprecation_message] << deprecation_message.too_many_warnings_message
            end
          end

          def deprecation_summary
            messages = @deprecation_messages.values.flatten
            return unless messages.any?

            print_deferred_deprecation_warnings(messages)

            summary_stream.puts "\n#{pluralize(deprecation_formatter.count, 'deprecation warning')} total"
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
