RSpec::Support.require_rspec_core "formatters/helpers"
require 'stringio'

module RSpec
  module Core
    module Formatters

      # @private
      # The `LegacyFormatter` is used to wrap older RSpec 2.x style formatters
      # for the new 3.x implementation. It takes care of registering all the
      # old notifications and translating them to the older formatter.
      #
      # @see RSpec::Core::Formatters::BaseFormatter
      class LegacyFormatter
        NOTIFICATIONS = %W[start message example_group_started example_group_finished example_started
                           example_passed example_failed example_pending start_dump dump_pending
                           dump_failures dump_summary seed close stop deprecation deprecation_summary]

        # @private
        module LegacyInterface

          def start(count)
            super Notifications::CountNotification.new(count)
          end

          def example_group_started(group)
            super Notifications::GroupNotification.new(group) if defined?(super)
          end

          def example_group_finished(group)
            super Notifications::GroupNotification.new(group) if defined?(super)
          end

          def example_started(example)
            super Notifications::ExampleNotification.new(example) if defined?(super)
          end

          def example_passed(example)
            super Notifications::ExampleNotification.new(example) if defined?(super)
          end

          def example_pending(example)
            super Notifications::ExampleNotification.new(example) if defined?(super)
          end

          def example_failed(example)
            super Notifications::ExampleNotification.new(example) if defined?(super)
          end

          def message(message)
            super Notifications::MessageNotification.new(message) if defined?(super)
          end

          attr_reader :duration, :example_count, :failure_count, :pending_count
          def dump_summary(duration, examples, failures, pending)
            @duration      = duration
            @example_count = examples
            @failure_count = failures
            @pending_count = pending
            super Notifications::SummaryNotification.new(duration, examples, failures, pending) if defined?(super)
          end

          def seed(seed)
            super Notifications::SeedNotification.new(seed, true) if defined?(super)
          end

          def start_dump
            super(Notifications::NullNotification) if defined?(super)
          end

          def dump_failures
            super(Notifications::NullNotification) if defined?(super)
          end

          def dump_pending
            super(Notifications::NullNotification) if defined?(super)
          end

          def close
            super(Notifications::NullNotification) if defined?(super)
          end

          def stop
            super(Notifications::NullNotification) if defined?(super)
          end
        end

        # @private
        module LegacyColorSupport
          def red(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#red", :replacement => "#failure_color")
            color(text, :red)
          end

          def green(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#green", :replacement => "#success_color")
            color(text, :green)
          end

          def yellow(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#yellow", :replacement => "#pending_color")
            color(text, :yellow)
          end

          def blue(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#blue", :replacement => "#fixed_color")
            color(text, :blue)
          end

          def magenta(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#magenta")
            color(text, :magenta)
          end

          def cyan(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#cyan", :replacement => "#detail_color")
            color(text, :cyan)
          end

          def white(text)
            RSpec.deprecate("RSpec::Core::Formatters::BaseTextFormatter#white", :replacement => "#default_color")
            color(text, :white)
          end

          # @private
          module ConstantLookup
            def const_missing(name)
              base_name = "RSpec::Core::Formatters::BaseTextFormatter"
              case name
              when :VT100_COLORS then
                RSpec.deprecate("#{base_name}::VT100_COLORS", :replacement => "RSpec::Core::Formatters::ConsoleCodes.code_for(code_or_symbol)")
                RSpec::Core::Formatters::ConsoleCodes::VT100_CODES
              when :VT100_COLOR_CODES then
                RSpec.deprecate("#{base_name}::VT100_COLOR_CODES", :replacement => "RSpec::Core::Formatters::ConsoleCodes.code_for(code_or_symbol)")
                RSpec::Core::Formatters::ConsoleCodes::VT100_CODE_VALUES
              else
                super
              end
            end
          end

          # These are part of the deprecated interface, so no individual deprecations
          def color_code_for(code_or_symbol)
            ConsoleCodes.console_code_for(code_or_symbol)
          end

          def colorize(text, code_or_symbol)
            ConsoleCodes.wrap(text, code_or_symbol)
          end

          def colorize_summary(summary)
            if failure_count > 0
              color(summary, RSpec.configuration.failure_color)
            elsif pending_count > 0
              color(summary, RSpec.configuration.pending_color)
            else
              color(summary, RSpec.configuration.success_color)
            end
          end
        end

        # @api private
        attr_reader :formatter

        # @api public
        #
        # @param formatter_class [Class] formatter class to build
        # @param args [Array<IO, Object>] arguments for the formatter, (usually IO but don't have to be)
        def initialize(formatter_class, *args)
          if defined?(BaseFormatter) && formatter_class.ancestors.include?(BaseFormatter)
            formatter_class.class_exec do
              include LegacyInterface
            end
          end
          if defined?(BaseTextFormatter) && formatter_class.ancestors.include?(BaseTextFormatter)
            formatter_class.class_exec do
              include LegacyColorSupport
              extend  LegacyColorSupport::ConstantLookup
            end
          end
          @formatter = formatter_class.new(*args)
        end

        # @api public
        #
        # This method is invoked during the setup phase to register
        # a formatters with the reporter
        #
        # @return [Array] notifications the legacy formatter implements
        def notifications
          @notifications ||= NOTIFICATIONS.select { |m| @formatter.respond_to? m }
        end

        # @api public
        #
        # @param notification [NullNotification]
        def start(notification)
          @formatter.start notification.count
        end

        # @api public
        #
        # @param notification [GroupNotification] containing example_group subclass of `RSpec::Core::ExampleGroup`
        def example_group_started(notification)
          @formatter.example_group_started notification.group
        end

        # @api public
        #
        # @param notification [GroupNotification] containing example_group subclass of `RSpec::Core::ExampleGroup`
        def example_group_finished(notification)
          @formatter.example_group_finished notification.group
        end

        # @api public
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_started(notification)
          @formatter.example_started notification.example
        end

        # @api public
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_passed(notification)
          @formatter.example_passed notification.example
        end

        # @api public
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_pending(notification)
          @formatter.example_pending notification.example
        end

        # @api public
        #
        # @param notification [ExampleNotification] containing example subclass of `RSpec::Core::Example`
        def example_failed(notification)
          @formatter.example_failed notification.example
        end

        # @api public
        #
        # @param notification [MessageNotification] containing message
        def message(notification)
          @formatter.message notification.message
        end

        # @api public
        #
        # @param notification [NullNotification]
        def stop(notification)
          @formatter.stop
        end

        # @api public
        #
        # @param notification [NullNotification]
        def start_dump(notification)
          @formatter.start_dump
        end

        # @api public
        #
        # @param notification [NullNotification]
        def dump_failures(notification)
          @formatter.dump_failures
        end

        # @api public
        #
        # @param summary [Notifications::SummaryNotification]
        def dump_summary(summary)
          @formatter.dump_summary summary.duration, summary.example_count, summary.failure_count, summary.pending_count
        end

        # @api public
        #
        # @param notification [NullNotification]
        def dump_pending(notification)
          @formatter.dump_pending
        end

        # @api public
        #
        # @param notification [NullNotification]
        def dump_profile(notification)
          @formatter.dump_profile
        end

        # @api public
        #
        # @param notification [SeedNotification] containing the seed
        def seed(notification)
          @formatter.seed notification.seed
        end

        # @api public
        #
        # @param notification [NullNotification]
        def close(notification)
          @formatter.close
        end

      end
    end
  end
end
