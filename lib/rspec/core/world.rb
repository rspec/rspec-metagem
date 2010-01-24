module Rspec
  module Core
    class World

      attr_reader :behaviours

      def initialize
        @behaviours = []
      end

      def filter
        Rspec::Core.configuration.filter
      end

      def exclusion_filter
        Rspec::Core.configuration.exclusion_filter
      end

      def shared_behaviours
        @shared_behaviours ||= {}
      end

      def behaviours_to_run
        return @behaviours_to_run if @behaviours_to_run

        if filter || exclusion_filter
          @behaviours_to_run = filter_behaviours

          if @behaviours_to_run.size == 0 && Rspec::Core.configuration.run_all_when_everything_filtered?
            Rspec::Core.configuration.puts "No examples were matched by #{filter.inspect}, running all"
            # reset the behaviour list to all behaviours, and add back all examples
            @behaviours_to_run = @behaviours
            @behaviours.each { |b| b.examples_to_run.replace(b.examples) }
          else
            Rspec::Core.configuration.puts "Run filtered using #{filter.inspect}"          
          end
        else
          @behaviours_to_run = @behaviours
          @behaviours.each { |b| b.examples_to_run.replace(b.examples) }
        end      

        @behaviours_to_run
      end

      def total_examples_to_run
        @total_examples_to_run ||= behaviours_to_run.inject(0) { |sum, b| sum += b.examples_to_run.size }
      end

      def filter_behaviours
        behaviours.inject([]) do |list_of_behaviors, _behavior|
          examples = _behavior.examples
          examples = apply_exclusion_filters(examples, exclusion_filter) if exclusion_filter
          examples = apply_inclusion_filters(examples, filter) if filter
          examples.uniq!
          _behavior.examples_to_run.replace(examples)
          if examples.empty?
            list_of_behaviors << nil
          else
            list_of_behaviors << _behavior
          end
        end.compact
      end

      def find(collection, type_of_filter=:positive, conditions={})
        negative = type_of_filter != :positive

        collection.select do |item|
          # negative conditions.any?, positive conditions.all? ?????
          result = conditions.all? do |filter_on, filter| 
            apply_condition(filter_on, filter, item.metadata)
          end
          negative ? !result : result
        end
      end

      def apply_inclusion_filters(collection, conditions={})
        find(collection, :positive, conditions)
      end

      def apply_exclusion_filters(collection, conditions={})
        find(collection, :negative, conditions)
      end

      def apply_condition(filter_on, filter, metadata)
        return false if metadata.nil?

        case filter
        when Hash
          filter.all? { |k, v| apply_condition(k, v, metadata[filter_on]) }
        when Regexp
          metadata[filter_on] =~ filter
        when Proc
          filter.call(metadata[filter_on]) rescue false
        else
          metadata[filter_on] == filter
        end
      end

    end
  end
end
