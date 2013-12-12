require 'rspec/core/formatters/helpers'
require 'stringio'

module RSpec
  module Core
    module Formatters

      # The `LegacyFormatter` is used to wrap older RSpec 2.x style formatters
      # for the new 3.x implementation. It takes care of registering all the
      # old notifications and translating them to the older formatter.
      #
      # @see RSpec::Core::Formatters::BaseFormatter
      class LegacyFormatter
        NOTIFICATIONS = %W[start message example_group_started example_group_finished example_started
                           example_passed example_failed example_pending start_dump dump_pending
                           dump_failures dump_summary seed close stop deprecation deprecation_summary].map(&:to_sym)

        # @api public
        #
        # @param formatter
        def initialize(oldstyle_formatter)
          @formatter = oldstyle_formatter
        end

        # @api public
        #
        # This method is invoked during the setup phase to register
        # a formatters with the reporter
        #
        def notifications
          @notifications ||= NOTIFICATIONS.select { |m| @formatter.respond_to? m }
        end

        # @api public
        #
        # @param example_count
        def start(example_count)
          @formatter.start example_count
        end

        # @api public
        #
        # @param example_group
        def example_group_started(example_group)
          @formatter.example_group_started example_group
        end

        # @api public
        #
        # @param example_group
        def example_group_finished(example_group)
          @formatter.example_group_finished example_group
        end

        # @api public
        #
        # @param example
        def example_started(example)
          @formatter.example_started example
        end

        # @api public
        #
        # @param example
        def example_passed(example)
          @formatter.example_passed example
        end

        # @api public
        #
        # @param example
        def example_pending(example)
          @formatter.example_pending example
        end

        # @api public
        #
        # @param example
        def example_failed(example)
          @formatter.example_failed example
        end

        # @api public
        #
        # @param message
        def message(message)
          @formatter.message message
        end

        # @api public
        #
        def stop
          @formatter.stop
        end

        # @api public
        #
        def start_dump
          @formatter.start_dump
        end

        # @api public
        #
        def dump_failures
          @formatter.dump_failures
        end

        # @api public
        #
        # @param duration
        # @param example_count
        # @param failure_count
        # @param pending_count
        def dump_summary(duration, example_count, failure_count, pending_count)
          @formatter.dump_summary duration, example_count, failure_count, pending_count
        end

        # @api public
        #
        def dump_pending
          @formatter.dump_pending
        end

        # @api public
        #
        def dump_profile
          @formatter.dump_profile
        end

        # @api public
        #
        # @param seed
        def seed(number)
          @formatter.seed number
        end

        # @api public
        #
        def close
          @formatter.close
        end

      end
    end
  end
end
