module RSpec

  module Core

    module Formatters

      class ProgressFormatter < BaseTextFormatter

        def output_for(example)
          case example.execution_result[:status]
          when 'failed' then colorise('F', example.execution_result[:exception_encountered])
          when 'pending' then yellow('*')
          when 'passed' then green('.')
          else
            red(example.execution_result[:status])
          end
        end

        def example_finished(example)
          super
          output.print output_for(example)
        end

        def start_dump(duration)
          super
          output.puts
          output.flush
        end

      end

    end

  end

end