require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class DocumentationFormatter < BaseTextFormatter
        Formatters.register self, :example_group_started, :example_group_finished,
                                  :example_passed, :example_pending, :example_failed

        def initialize(output)
          super
          @group_level = 0
        end

        def example_group_started(notification)
          super

          output.puts if @group_level == 0
          output.puts "#{current_indentation}#{notification.group.description.strip}"

          @group_level += 1
        end

        def example_group_finished(notification)
          @group_level -= 1
        end

        def example_passed(passed)
          output.puts passed_output(passed.example)
        end

        def example_pending(pending)
          super
          output.puts pending_output(pending.example, pending.example.execution_result[:pending_message])
        end

        def example_failed(failure)
          super
          output.puts failure_output(failure.example, failure.example.execution_result[:exception])
        end

      private

        def passed_output(example)
          success_color("#{current_indentation}#{example.description.strip}")
        end

        def pending_output(example, message)
          pending_color("#{current_indentation}#{example.description.strip} (PENDING: #{message})")
        end

        def failure_output(example, exception)
          failure_color("#{current_indentation}#{example.description.strip} (FAILED - #{next_failure_index})")
        end

        def next_failure_index
          @next_failure_index ||= 0
          @next_failure_index += 1
        end

        def current_indentation
          '  ' * @group_level
        end

        def example_group_chain
          example_group.parent_groups.reverse
        end

      end
    end
  end
end
