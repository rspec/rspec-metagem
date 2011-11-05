module RSpec
  module Core
    class World

      include RSpec::Core::Hooks

      attr_reader :example_groups, :filtered_examples, :wants_to_quit
      attr_writer :wants_to_quit

      def initialize(configuration=RSpec.configuration)
        @configuration = configuration
        @example_groups = [].extend(Extensions::Ordered)
        @filtered_examples = Hash.new { |hash,group|
          hash[group] = begin
            examples = group.examples.dup
            examples = filter.filter(examples)
            examples.uniq
            examples.extend(Extensions::Ordered)
          end
        }
      end

      def reset
        example_groups.clear
      end

      # TODO - fix me
      def filter
        @configuration.instance_variable_get("@filter")
      end

      def register(example_group)
        example_groups << example_group
        example_group
      end

      def inclusion_filter
        @configuration.inclusion_filter
      end

      def exclusion_filter
        @configuration.exclusion_filter
      end

      def configure_group(group)
        @configuration.configure_group(group)
      end

      def shared_example_groups
        @shared_example_groups ||= {}
      end

      def example_count
        example_groups.collect {|g| g.descendants}.flatten.inject(0) { |sum, g| sum += g.filtered_examples.size }
      end

      def preceding_declaration_line(filter_line)
        declaration_line_numbers.sort.inject(nil) do |highest_prior_declaration_line, line|
          line <= filter_line ? line : highest_prior_declaration_line
        end
      end

      def reporter
        @configuration.reporter
      end

      def announce_filters
        filter_announcements = []

        if @configuration.run_all_when_everything_filtered? && example_count.zero?
          reporter.message( "No examples matched #{inclusion_filter.description}. Running all.")
          filtered_examples.clear
          inclusion_filter.clear
        end

        announce_inclusion_filter filter_announcements
        announce_exclusion_filter filter_announcements

        if example_count.zero?
          example_groups.clear
          if filter_announcements.empty?
            reporter.message("No examples found.")
          elsif !inclusion_filter.empty?
            message = "No examples matched #{inclusion_filter.description}."
            if @configuration.run_all_when_everything_filtered?
              message << " Running all."
            end
            reporter.message(message)
          elsif !exclusion_filter.empty?
            reporter.message(
              "No examples were matched. Perhaps #{exclusion_filter.description} is excluding everything?")
          end
        elsif !filter_announcements.empty?
          reporter.message("Run filtered #{filter_announcements.join(', ')}")
        end
      end

      def announce_inclusion_filter(announcements)
        unless inclusion_filter.empty?
          announcements << "including #{inclusion_filter.description}"
        end
      end

      def announce_exclusion_filter(announcements)
        unless exclusion_filter.empty_without_conditional_filters?
          announcements << "excluding #{exclusion_filter.description}"
        end
      end

      def find_hook(hook, scope, group, example = nil)
        @configuration.find_hook(hook, scope, group, example)
      end

    private

      def declaration_line_numbers
        @line_numbers ||= example_groups.inject([]) do |lines, g|
          lines + g.declaration_line_numbers
        end
      end

    end
  end
end
