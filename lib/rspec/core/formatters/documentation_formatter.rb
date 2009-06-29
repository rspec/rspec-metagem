module Rspec

  module Core

    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        attr_reader :previous_nested_behaviours

        def initialize
          super
          @previous_nested_behaviours = []
        end

        def add_behaviour(behaviour)
          super

          described_behaviour_chain.each_with_index do |nested_behaviour, i|
            unless nested_behaviour == previous_nested_behaviours[i]
              at_root_level = (i == 0)
              desc_or_name = at_root_level ? nested_behaviour.name : nested_behaviour.description
              output.puts if at_root_level
              output.puts "#{'  ' * i}#{desc_or_name}"
            end
          end

          @previous_nested_behaviours = described_behaviour_chain
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
          '  ' * previous_nested_behaviours.size
        end

        def described_behaviour_chain
          behaviour.ancestors
        end

      end

    end

  end

end