module Rspec
  module Core
    class World

      attr_reader :example_groups

      def initialize
        @example_groups = []
      end

      def inclusion_filter
        Rspec.configuration.filter
      end

      def exclusion_filter
        Rspec.configuration.exclusion_filter
      end

      def shared_example_groups
        @shared_example_groups ||= {}
      end

      def example_groups_to_run
        if inclusion_filter
          if Rspec.configuration.run_all_when_everything_filtered? && total_examples_to_run == 0
            Rspec.configuration.puts "No examples were matched by #{inclusion_filter.inspect}, running all"
            Rspec.configuration.clear_inclusion_filter
          else
            Rspec.configuration.puts "Run filtered using #{inclusion_filter.inspect}"          
          end
        end      
        example_groups
      end

      def total_examples_to_run
        example_groups.collect {|g| g.descendents}.flatten.inject(0) { |sum, g| sum += g.examples_to_run.size }
      end

      def apply_inclusion_filters(examples, conditions={})
        examples.select &all_apply?(conditions)
      end

      alias_method :find, :apply_inclusion_filters

      def apply_exclusion_filters(examples, conditions={})
        examples.reject &all_apply?(conditions)
      end

      def preceding_declaration_line(filter_line) 
        declaration_line_numbers.inject(nil) do |highest_prior_declaration_line, line|
          line <= filter_line ? line : highest_prior_declaration_line
        end
      end
      
    private

      def all_apply?(conditions)
        lambda {|example| example.metadata.all_apply?(conditions)}
      end

      def declaration_line_numbers
        @line_numbers ||= example_groups.inject([]) do |lines, g|
          lines + g.declaration_line_numbers
        end
      end
      
    end
  end
end
