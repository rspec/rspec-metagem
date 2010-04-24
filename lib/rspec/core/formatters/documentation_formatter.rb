module Rspec

  module Core

    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        def initialize
          super
          @previous_nested_example_groups = []
        end

        def add_example_group(example_group)
          super

          described_example_group_chain.each_with_index do |nested_example_group, i|
            unless nested_example_group == @previous_nested_example_groups[i]
              output.puts if i == 0
              output.puts "#{'  ' * i}#{nested_example_group.description}"
            end
          end

          @previous_nested_example_groups = described_example_group_chain
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
          expectation_not_met = exception.is_a?(::Rspec::Expectations::ExpectationNotMetError)

          message = if expectation_not_met
            "#{current_indentation}#{example.description} (FAILED)"
          else
            "#{current_indentation}#{example.description} (ERROR)"
          end

          expectation_not_met ? red(message) : magenta(message)
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

        def described_example_group_chain
          example_group.ancestor_example_groups
        end

      end

    end

  end

end
