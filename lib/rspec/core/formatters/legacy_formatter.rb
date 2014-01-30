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
                           dump_failures dump_summary seed close stop deprecation deprecation_summary]

        module LegacyInterface

          def start(count)
            super CountNotification.new(count)
          end

          def example_group_started(group)
            super GroupNotification.new(group) if defined?(super)
          end

          def example_group_finished(group)
            super GroupNotification.new(group) if defined?(super)
          end

          def example_started(example)
            super ExampleNotification.new(example) if defined?(super)
          end

          def example_passed(example)
            super ExampleNotification.new(example) if defined?(super)
          end

          def example_pending(example)
            super ExampleNotification.new(example) if defined?(super)
          end

          def example_failed(example)
            super ExampleNotification.new(example) if defined?(super)
          end

          def message(message)
            super MessageNotification.new(message) if defined?(super)
          end

          def dump_summary(duration, examples, failures, pending)
            super SummaryNotification.new(duration, examples, failures, pending) if defined?(super)
          end

          def seed(seed)
            super SeedNotification.new(seed, true) if defined?(super)
          end


          def start_dump
            super(NullNotification.instance) if defined?(super)
          end

          def dump_failures
            super(NullNotification.instance) if defined?(super)
          end

          def dump_pending
            super(NullNotification.instance) if defined?(super)
          end

          def dump_profile
            super(NullNotification.instance) if defined?(super)
          end

          def close
            super(NullNotification.instance) if defined?(super)
          end

          def stop
            super(NullNotification.instance) if defined?(super)
          end
        end

        # @api private
        def self.can_detect?(formatter)
          return true unless formatter.respond_to? :notifications
          return true if formatter.respond_to?(:summary) && formatter.method(:summary).arity != 1
          formatter.method(:notifications).owner != formatter.class
        end

        # @api public
        #
        # @param formatter
        def initialize(oldstyle_formatter)
          @formatter = oldstyle_formatter
          if @formatter.respond_to?(:notifications)
            @formatter.class.class_eval do
              include LegacyInterface
            end
          end
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
        def start(notification)
          @formatter.start notification.count
        end

        # @api public
        #
        # @param example_group
        def example_group_started(notification)
          @formatter.example_group_started notification.group
        end

        # @api public
        #
        # @param example_group
        def example_group_finished(notification)
          @formatter.example_group_finished notification.group
        end

        # @api public
        #
        # @param example
        def example_started(notification)
          @formatter.example_started notification.example
        end

        # @api public
        #
        # @param example
        def example_passed(notification)
          @formatter.example_passed notification.example
        end

        # @api public
        #
        # @param example
        def example_pending(notification)
          @formatter.example_pending notification.example
        end

        # @api public
        #
        # @param example
        def example_failed(notification)
          @formatter.example_failed notification.example
        end

        # @api public
        #
        # @param message
        def message(notification)
          @formatter.message notification.message
        end

        # @api public
        #
        def stop(notification)
          @formatter.stop
        end

        # @api public
        #
        def start_dump(notification)
          @formatter.start_dump
        end

        # @api public
        #
        def dump_failures(notification)
          @formatter.dump_failures
        end

        # @api public
        #
        # @param duration
        # @param example_count
        # @param failure_count
        # @param pending_count
        def dump_summary(summary)
          @formatter.dump_summary summary.duration, summary.examples, summary.failures, summary.pending
        end

        # @api public
        #
        def dump_pending(notification)
          @formatter.dump_pending
        end

        # @api public
        #
        def dump_profile(notification)
          @formatter.dump_profile
        end

        # @api public
        #
        # @param seed
        def seed(notification)
          @formatter.seed notification.seed
        end

        # @api public
        #
        def close(notification)
          @formatter.close
        end

      end
    end
  end
end
