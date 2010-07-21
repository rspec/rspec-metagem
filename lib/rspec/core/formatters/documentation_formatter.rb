module RSpec
  module Core
    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        def initialize(output)
          super(output)
          @previous_nested_example_groups = []
        end

        def example_group_started(example_group)
          super

          example_group_chain.each_with_index do |nested_example_group, i|
            unless nested_example_group == @previous_nested_example_groups[i]
              output.puts if i == 0
              output.puts "#{'  ' * i}#{nested_example_group.description}"
            end
          end

          @previous_nested_example_groups = example_group_chain
        end

        def example_passed(example)
          super
          output.puts passed_output(example)
        end

        def example_pending(example)
          super
          output.puts pending_output(example, example.execution_result[:pending_message])
        end

        def example_failed(example)
          super
          output.puts failure_output(example, example.execution_result[:exception_encountered])
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
