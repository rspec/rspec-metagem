module RSpec
  module Core
    module Formatters
      # @private
      class ExceptionPresenter
        attr_reader :exception, :example, :description, :message_color, :detail_formatter, :extra_detail_formatter
        private :message_color, :detail_formatter, :extra_detail_formatter

        def initialize(exception, example, options={})
          @exception              = exception
          @example                = example
          @message_color          = options.fetch(:message_color)          { RSpec.configuration.failure_color }
          @description            = options.fetch(:description_formatter)  { Proc.new { example.full_description } }.call(self)
          @detail_formatter       = options.fetch(:detail_formatter)       { Proc.new {} }
          @extra_detail_formatter = options.fetch(:extra_detail_formatter) { Proc.new {} }
          @indentation            = options.fetch(:indentation, 2)
          @failure_lines          = options[:failure_lines]
        end

        def message_lines
          add_shared_group_lines(failure_lines, Notifications::NullColorizer)
        end

        def colorized_message_lines(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
          add_shared_group_lines(failure_lines, colorizer).map do |line|
            colorizer.wrap line, message_color
          end
        end

        def formatted_backtrace
          backtrace_formatter.format_backtrace(exception.backtrace, example.metadata)
        end

        def colorized_formatted_backtrace(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
          formatted_backtrace.map do |backtrace_info|
            colorizer.wrap "# #{backtrace_info}", RSpec.configuration.detail_color
          end
        end

        def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
          alignment_basis = "#{' ' * @indentation}#{failure_number}) "
          indentation = ' ' * alignment_basis.length

          "\n#{alignment_basis}#{description}#{detail_formatter.call(example, colorizer, indentation)}" \
          "\n#{formatted_message_and_backtrace(colorizer, indentation)}" \
          "#{extra_detail_formatter.call(failure_number, colorizer, indentation)}"
        end

        def failure_slash_error_line
          @failure_slash_error_line ||= "Failure/Error: #{read_failed_line.strip}"
        end

      private

        if String.method_defined?(:encoding)
          def encoding_of(string)
            string.encoding
          end

          def encoded_string(string)
            RSpec::Support::EncodedString.new(string, Encoding.default_external)
          end
        else # for 1.8.7
          # :nocov:
          def encoding_of(_string)
          end

          def encoded_string(string)
            RSpec::Support::EncodedString.new(string)
          end
          # :nocov:
        end

        def backtrace_formatter
          RSpec.configuration.backtrace_formatter
        end

        def exception_class_name
          name = exception.class.name.to_s
          name = "(anonymous error class)" if name == ''
          name
        end

        def failure_lines
          @failure_lines ||=
            begin
              lines = []
              lines << failure_slash_error_line unless (description == failure_slash_error_line)
              lines << "#{exception_class_name}:" unless exception_class_name =~ /RSpec/
              encoded_string(exception.message.to_s).split("\n").each do |line|
                lines << "  #{line}"
              end
              lines
            end
        end

        def add_shared_group_lines(lines, colorizer)
          example.metadata[:shared_group_inclusion_backtrace].each do |frame|
            lines << colorizer.wrap(frame.description, RSpec.configuration.default_color)
          end

          lines
        end

        def read_failed_line
          matching_line = find_failed_line
          unless matching_line
            return "Unable to find matching line from backtrace"
          end

          file_path, line_number = matching_line.match(/(.+?):(\d+)(|:\d+)/)[1..2]

          if File.exist?(file_path)
            File.readlines(file_path)[line_number.to_i - 1] ||
              "Unable to find matching line in #{file_path}"
          else
            "Unable to find #{file_path} to read failed line"
          end
        rescue SecurityError
          "Unable to read failed line"
        end

        def find_failed_line
          example_path = example.metadata[:absolute_file_path].downcase
          exception.backtrace.find do |line|
            next unless (line_path = line[/(.+?):(\d+)(|:\d+)/, 1])
            File.expand_path(line_path).downcase == example_path
          end
        end

        def formatted_message_and_backtrace(colorizer, indentation)
          lines = colorized_message_lines(colorizer) + colorized_formatted_backtrace(colorizer)

          formatted = ""

          lines.each do |line|
            formatted << RSpec::Support::EncodedString.new("#{indentation}#{line}\n", encoding_of(formatted))
          end

          formatted
        end
      end

      # @private
      class MultipleExpectationsNotMetPresenterOptions
        def self.for(exception, example, options={})
          new(exception, example, options).presenter_options
        end

        attr_reader :exception, :example, :options

        def initialize(exception, example, options={})
          @exception = exception
          @example   = example
          @options   = options
        end

        def presenter_options
          options.merge(
            :failure_lines          => [],
            :detail_formatter       => method(:failure_summary),
            :extra_detail_formatter => method(:formatted_sub_failure_list)
          )
        end

      private

        def failure_summary(_example, colorizer, indentation)
          # TODO: ensure this is printed in pending color when appropriate
          colorizer.wrap("\n#{indentation}#{exception.summary}.", RSpec.configuration.failure_color)
        end

        def formatted_sub_failure_list(failure_number, colorizer, indentation)
          # TODO: message_color
          exception.all_exceptions.each_with_index.map do |failure, index|
            ExceptionPresenter.new(
              convert_to_relative_backtrace(failure), example,
              :description_formatter => :failure_slash_error_line.to_proc,
              :indentation           => indentation.length
            ).fully_formatted("#{failure_number}.#{index + 1}", colorizer)
          end.join
        end

        def convert_to_relative_backtrace(failure)
          failure = failure.dup
          failure.set_backtrace(failure.backtrace[0..-exception.backtrace.size])
          failure
        end
      end
    end
  end
end
