module RSpec
  module Core
    class FilterManager
      DEFAULT_EXCLUSIONS = {
        :if     => lambda { |value, metadata| metadata.has_key?(:if) && !value },
        :unless => lambda { |value| value }
      }

      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      module Describable
        PROC_HEX_NUMBER = /0x[0-9a-f]+@/
        PROJECT_DIR = File.expand_path('.')

        def description
          reject { |k, v| RSpec::Core::FilterManager::DEFAULT_EXCLUSIONS[k] == v }.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
        end

        def empty_without_conditional_filters?
          reject { |k, v| RSpec::Core::FilterManager::DEFAULT_EXCLUSIONS[k] == v }.empty?
        end

        def reject
          super rescue {}
        end

        def empty?
          super rescue false
        end
      end

      module BackwardCompatibility
        # This is to support a use case that probably doesn't exist: overriding
        # the if/unless procs.
        #
        # TODO - add deprecation warning on :if/:unless
        def update(orig, opposite, *updates)
          if updates.last.has_key?(:unless)
            @exclusions[:unless] = updates.last.delete(:unless)
          end
          if updates.last.has_key?(:if)
            @exclusions[:if] = updates.last.delete(:if)
          end

          super
        end
      end

      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions = DEFAULT_EXCLUSIONS.dup.extend(Describable)
        @inclusions = {}.extend(Describable)
        extend(BackwardCompatibility)
      end

      def add_location(file_path, line_numbers)
        # filter_locations is a hash of expanded paths to arrays of line
        # numbers to match against. e.g.
        #   { "path/to/file.rb" => [37, 42] }
        filter_locations = @inclusions[:locations] ||= Hash.new {|h,k| h[k] = []}
        @exclusions.clear
        @inclusions.clear
        filter_locations[File.expand_path(file_path)].push(*line_numbers)
        include :locations => filter_locations
      end

      def empty?
        inclusions.empty? && exclusions.empty_without_conditional_filters?
      end

      def prune(examples)
        examples.select {|e| !exclude?(e) && include?(e)}
      end

      def exclude?(example)
        @exclusions.empty? ? false : example.any_apply?(@exclusions)
      end

      def include?(example)
        @inclusions.empty? ? true : example.any_apply?(@inclusions)
      end

      def exclude(*args)
        update(@exclusions, @inclusions, *args)
      end

      def include(*args)
        return if already_set_standalone_filter?

        is_standalone_filter?(args.last) ? @inclusions.replace(args.last) : update(@inclusions, @exclusions, *args)
      end

      def update(orig, opposite, *updates)
        if updates.length == 2
          if updates[0] == :replace
            updated = updates.last
          else
            updated = updates.last.merge(orig)
            opposite.each_key {|k| updated.delete(k)}
          end
          orig.replace(updated)
        else
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end
      end

      def already_set_standalone_filter?
        is_standalone_filter?(inclusions)
      end

      def is_standalone_filter?(filter)
        STANDALONE_FILTERS.any? {|key| filter.has_key?(key)}
      end
    end
  end
end
