module RSpec
  module Core
    class Filter
      DEFAULT_EXCLUSIONS = {
        :if     => lambda { |value, metadata| metadata.has_key?(:if) && !value },
        :unless => lambda { |value| value }
      }

      module Describable
        PROC_HEX_NUMBER = /0x[0-9a-f]+@/
        PROJECT_DIR = File.expand_path('.')

        def description
          reject { |k, v| RSpec::Core::Filter::DEFAULT_EXCLUSIONS[k] == v }.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
        end

        def empty_without_conditional_filters?
          reject { |k, v| RSpec::Core::Filter::DEFAULT_EXCLUSIONS[k] == v }.empty?
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

      def empty?
        inclusions.empty? && exclusions.empty_without_conditional_filters?
      end

      def prune(examples)
        examples.select {|e| !exclude?(e) && include?(e)}
      end

      alias_method :filter, :prune

      def exclude?(example)
        @exclusions.empty? ? false : example.any_apply?(@exclusions)
      end

      def include?(example)
        @inclusions.empty? ? true : example.any_apply?(@inclusions)
      end

      def exclude(*args)
        @exclusions = update(@exclusions, @inclusions, *args)
      end

      def include(*args)
        @inclusions = update(@inclusions, @exclusions, *args)
      end

      def update(orig, opposite, *updates)
        if updates.length == 2
          updated = updates.last.merge(orig)
          opposite.each_key {|k| updated.delete(k)}
          orig.replace(updated)
        else
          orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
        end
      end
    end
  end
end
