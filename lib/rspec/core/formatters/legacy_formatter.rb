require 'rspec/core/formatters/helpers'
require 'stringio'

module RSpec
  module Core
    module Formatters
      class LegacyFormatter
        NOTIFICATIONS = %W[start message example_group_started example_group_finished example_started
                           example_passed example_failed example_pending start_dump dump_pending
                           dump_failures dump_summary seed close stop deprecation deprecation_summary].map(&:to_sym)

        def initialize(oldstyle_formatter)
          @formatter = oldstyle_formatter
        end

        def notifications
          @notifications ||= NOTIFICATIONS.select { |m| @formatter.respond_to? m }
        end

        def start(example_count)
          @formatter.start example_count
        end

        def example_group_started(example_group)
          @formatter.example_group_started example_group
        end

        def example_group_finished(example_group)
          @formatter.example_group_finished example_group
        end

        def example_started(example)
          @formatter.example_started example
        end

        def example_passed(example)
          @formatter.example_passed example
        end

        def example_pending(example)
          @formatter.example_pending example
        end

        def example_failed(example)
          @formatter.example_failed example
        end

        def message(message)
          @formatter.message message
        end

        def stop
          @formatter.stop
        end

        def start_dump
          @formatter.start_dump
        end

        def dump_failures
          @formatter.dump_failures
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          @formatter.dump_summary duration, example_count, failure_count, pending_count
        end

        def dump_pending
          @formatter.dump_pending
        end

        def dump_profile
          @formatter.dump_profile
        end

        def seed(number)
          @formatter.seed number
        end

        def close
          @formatter.close
        end

      end
    end
  end
end
