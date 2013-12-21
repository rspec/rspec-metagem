module RSpec
  module Core
    # Manages the filtering of examples and groups by matching tags declared on
    # the command line or options files, or filters declared via
    # `RSpec.configure`, with hash key/values submitted within example group
    # and/or example declarations. For example, given this declaration:
    #
    #     describe Thing, :awesome => true do
    #       it "does something" do
    #         # ...
    #       end
    #     end
    #
    # That group (or any other with `:awesome => true`) would be filtered in
    # with any of the following commands:
    #
    #     rspec --tag awesome:true
    #     rspec --tag awesome
    #     rspec -t awesome:true
    #     rspec -t awesome
    #
    # Prefixing the tag names with `~` negates the tags, thus excluding this group with
    # any of:
    #
    #     rspec --tag ~awesome:true
    #     rspec --tag ~awesome
    #     rspec -t ~awesome:true
    #     rspec -t ~awesome
    #
    # ## Options files and command line overrides
    #
    # Tag declarations can be stored in `.rspec`, `~/.rspec`, or a custom
    # options file.  This is useful for storing defaults. For example, let's
    # say you've got some slow specs that you want to suppress most of the
    # time. You can tag them like this:
    #
    #     describe Something, :slow => true do
    #
    # And then store this in `.rspec`:
    #
    #     --tag ~slow:true
    #
    # Now when you run `rspec`, that group will be excluded.
    #
    # ## Overriding
    #
    # Of course, you probably want to run them sometimes, so you can override
    # this tag on the command line like this:
    #
    #     rspec --tag slow:true
    #
    # ## RSpec.configure
    #
    # You can also store default tags with `RSpec.configure`. We use `tag` on
    # the command line (and in options files like `.rspec`), but for historical
    # reasons we use the term `filter` in `RSpec.configure:
    #
    #     RSpec.configure do |c|
    #       c.filter_run_including :foo => :bar
    #       c.filter_run_excluding :foo => :bar
    #     end
    #
    # These declarations can also be overridden from the command line.
    #
    # @see RSpec.configure
    # @see Configuration#filter_run_including
    # @see Configuration#filter_run_excluding
    class FilterManager
      STANDALONE_FILTERS = [:locations, :line_numbers, :full_description]

      PROC_HEX_NUMBER = /0x[0-9a-f]+@/
      PROJECT_DIR = File.expand_path('.')

      def self.inspect_filter_hash(hash)
        hash.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
      end

      class InclusionFilterHash < Hash
        def description
          FilterManager.inspect_filter_hash self
        end
      end

      class ExclusionFilterHash < Hash
        CONDITIONAL_FILTERS = {
          :if     => lambda { |value| !value },
          :unless => lambda { |value| value }
        }

        def initialize(*)
          super
          CONDITIONAL_FILTERS.each {|k,v| store(k, v)}
        end

        def description
          FilterManager.inspect_filter_hash without_conditional_filters
        end

        def empty_without_conditional_filters?
          without_conditional_filters.empty?
        end

        private

        if RUBY_VERSION.to_f < 2.1
          def without_conditional_filters
            # On 1.8.7, Hash#reject returns a hash but Hash#select returns an array.
            reject {|k,v| CONDITIONAL_FILTERS[k] == v}
          end
        else
          def without_conditional_filters
            # On ruby 2.1 #reject on a subclass of Hash emits warnings, but #select does not.
            select {|k,v| CONDITIONAL_FILTERS[k] != v}
          end
        end
      end

      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions = ExclusionFilterHash.new
        @inclusions = InclusionFilterHash.new
      end

      def add_location(file_path, line_numbers)
        # locations is a hash of expanded paths to arrays of line
        # numbers to match against. e.g.
        #   { "path/to/file.rb" => [37, 42] }
        locations = @inclusions.delete(:locations) || Hash.new {|h,k| h[k] = []}
        locations[File.expand_path(file_path)].push(*line_numbers)

        replace_filters :locations => locations
      end

      def empty?
        inclusions.empty? && exclusions.empty_without_conditional_filters?
      end

      def prune(examples)
        examples.select {|e| !exclude?(e) && include?(e)}
      end

      def exclude(*args)
        merge(@exclusions, @inclusions, *args)
      end

      def exclude!(*args)
        replace(@exclusions, @inclusions, *args)
      end

      def exclude_with_low_priority(*args)
        reverse_merge(@exclusions, @inclusions, *args)
      end

      def exclude?(example)
        @exclusions.empty? ? false : example.any_apply?(@exclusions)
      end

      def include(*filters)
        set_standalone_filter(*filters) || merge(@inclusions, @exclusions, *filters)
      end

      def include!(*filters)
        set_standalone_filter(*filters) || replace(@inclusions, @exclusions, *filters)
      end

      def include_with_low_priority(*filters)
        set_standalone_filter(*filters) || reverse_merge(@inclusions, @exclusions, *filters)
      end

      def include?(example)
        @inclusions.empty? ? true : example.any_apply?(@inclusions)
      end

    private

      def set_standalone_filter(*args)
        if already_set_standalone_filter?
          true
        elsif is_standalone_filter?(args.last)
          replace_filters(args.last)
          true
        end
      end

      def replace_filters(rule)
        @inclusions.replace(rule)
        @exclusions.clear
      end

      def merge(orig, opposite, *updates)
        orig.merge!(updates.last).each_key {|k| opposite.delete(k)}
      end

      def replace(orig, opposite, *updates)
        updates.last.each_key {|k| opposite.delete(k)}
        orig.replace(updates.last)
      end

      def reverse_merge(orig, opposite, *updates)
        updated = updates.last.merge(orig)
        opposite.each_pair {|k,v| updated.delete(k) if updated[k] == v}
        orig.replace(updated)
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
