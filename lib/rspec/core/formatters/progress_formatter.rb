module RSpec
  module Core
    module Formatters

      class ProgressFormatter < BaseTextFormatter

        def example_passed(example)
          super
          output.print green('.')
        end

        def example_pending(example)
          super
          output.print yellow('*')
        end

        def example_failed(example)
          super
          output.print red('F')
        end

        def start_dump
          super
          output.puts
        end

      end

    end
  end
end
