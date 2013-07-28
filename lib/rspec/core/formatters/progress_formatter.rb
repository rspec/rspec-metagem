require 'rspec/core/formatters/base_text_formatter'
module RSpec
  module Core
    module Formatters
      class ProgressFormatter < BaseTextFormatter

        def notifications
          (super + [:example_passed, :example_pending, :example_failed, :start_dump]).uniq
        end

        def example_passed(example)
          output.print success_color('.')
        end

        def example_pending(example)
          super(example)
          output.print pending_color('*')
        end

        def example_failed(example)
          super(example)
          output.print failure_color('F')
        end

        def start_dump
          output.puts
        end

      end
    end
  end
end
