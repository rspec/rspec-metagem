module Rspec
  module Core
    class World

      attr_reader :example_groups

      def initialize
        @example_groups = []
      end

      def filter
        Rspec.configuration.filter
      end

      def exclusion_filter
        Rspec.configuration.exclusion_filter
      end

      def shared_example_groups
        @shared_example_groups ||= {}
      end

      def example_groups_to_run
        return @example_groups_to_run if @example_groups_to_run

        if filter || exclusion_filter
          @example_groups_to_run = filter_example_groups

          if @example_groups_to_run.size == 0 && Rspec.configuration.run_all_when_everything_filtered?
            Rspec.configuration.puts "No examples were matched by #{filter.inspect}, running all"
            # reset the behaviour list to all example groups, and add back all examples
            @example_groups_to_run = @example_groups
            @example_groups.each { |b| b.examples_to_run.replace(b.examples) }
          else
            Rspec.configuration.puts "Run filtered using #{filter.inspect}"          
          end
        else
          @example_groups_to_run = @example_groups
          @example_groups.each { |b| b.examples_to_run.replace(b.examples) }
        end      

        @example_groups_to_run
      end

      def total_examples_to_run
        @total_examples_to_run ||= example_groups_to_run.inject(0) { |sum, b| sum += b.examples_to_run.size }
      end

      def filter_example_groups
        example_groups.inject([]) do |list_of_example_groups, example_group|
          examples = example_group.examples
          examples = apply_exclusion_filters(examples, exclusion_filter) if exclusion_filter
          examples = apply_inclusion_filters(examples, filter) if filter
          examples.uniq!
          example_group.examples_to_run.replace(examples)
          if examples.empty?
            list_of_example_groups << nil
          else
            list_of_example_groups << example_group
          end
        end.compact
      end

      def apply_inclusion_filters(collection, conditions={})
        find(collection, :positive, conditions)
      end

      def apply_exclusion_filters(collection, conditions={})
        find(collection, :negative, conditions)
      end

      def find(collection, type_of_filter=:positive, conditions={})
        negative = type_of_filter != :positive

        collection.select do |item|
          # negative conditions.any?, positive conditions.all? ?????
          result = conditions.all? do |filter_on, filter| 
            item.metadata.apply_condition(filter_on, filter)
          end
          negative ? !result : result
        end
      end

    end
  end
end
