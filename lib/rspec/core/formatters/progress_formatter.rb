RSpec::Support.require_rspec_core "formatters/base_text_formatter"

module RSpec
  module Core
    module Formatters
      # @private
      class ProgressFormatter < BaseTextFormatter
        Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump

        def example_passed(notification)
          output.print color('.', :success)
        end

        def example_pending(notification)
          output.print color('*', :pending)
        end

        def example_failed(notification)
          output.print color('F', :failure)
        end

        def start_dump(notification)
          output.puts
        end

      end
    end
  end
end
