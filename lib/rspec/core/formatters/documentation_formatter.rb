module RSpec

  module Core

    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        def initialize
          super
          @previous_nested_example_groups = []
        end

        def add_example_group(example_group)
          super

          example_group_chain.each_with_index do |nested_example_group, i|
            unless nested_example_group == @previous_nested_example_groups[i]
              output.puts if i == 0
              output.puts "#{'  ' * i}#{nested_example_group.description}"
            end
          end

          @previous_nested_example_groups = example_group_chain
        end
        
        def output_for(example)
          case example.execution_result[:status]
          when 'failed'
            failure_output(example, example.execution_result[:exception_encountered])
          when 'pending'
            pending_output(example, example.execution_result[:pending_message])
          when 'passed'
            passed_output(example)
          else
            red(example.execution_result[:status])
          end
        end

        def example_finished(example)
          super
          output.puts output_for(example)
          output.flush
        end

        def failure_output(example, exception)
          red("#{current_indentation}#{example.description} (FAILED - #{next_failure_index})")
        end

        def next_failure_index
          @next_failure_index ||= 0
          @next_failure_index += 1
        end

        def passed_output(example)
          green("#{current_indentation}#{example.description}")
        end

        def pending_output(example, message)
          yellow("#{current_indentation}#{example.description} (PENDING: #{message})")
        end

        def current_indentation
          '  ' * @previous_nested_example_groups.size
        end

        def example_group_chain
          example_group.ancestors.reverse
        end

      end

    end

  end

end
