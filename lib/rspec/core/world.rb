module Rspec
  module Core
    class World

      attr_reader :example_groups

      def initialize
        @example_groups = []
      end

      def configuration
        Rspec.configuration
      end

      def inclusion_filter
        configuration.filter
      end

      def exclusion_filter
        configuration.exclusion_filter
      end

      def find_modules(group)
        configuration.find_modules(group)
      end

      def shared_example_groups
        @shared_example_groups ||= {}
      end

      def example_count
        example_groups.collect {|g| g.descendents}.flatten.inject(0) { |sum, g| sum += g.filtered_examples.size }
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
      
      def run_hook(hook, scope, group, example)
        find_hook(hook, scope, group).each { |blk| example.instance_eval(&blk) }
      end

      def find_hook(hook, scope, group)
        Rspec.configuration.hooks[hook][scope].select do |filters, block|
          group.all_apply?(filters)
        end.map { |filters, block| block }
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
