module RSpec
  module Core
    # @private
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
      attr_reader :exclusions, :inclusions

      def initialize
        @exclusions, @inclusions = FilterRules.build
      end

      # @api private
      #
      # @param file_path [String]
      # @param line_numbers [Array]
      def add_location(file_path, line_numbers)
        # locations is a hash of expanded paths to arrays of line
        # numbers to match against. e.g.
        #   { "path/to/file.rb" => [37, 42] }
        locations = inclusions.delete(:locations) || Hash.new { |h,k| h[k] = [] }
        locations[File.expand_path(file_path)].push(*line_numbers)
        inclusions.add_location(locations)
      end

      def empty?
        inclusions.empty? && exclusions.empty?
      end

      def prune(examples)
        if inclusions.standalone?
          base_exclusions = ExclusionRules.new
          examples.select {|e| !base_exclusions.include_example?(e) && include?(e) }
        else
          examples.select {|e| !exclude?(e) && include?(e)}
        end
      end

      def exclude(*args)
        exclusions.add(args.last)
      end

      def exclude_only(*args)
        exclusions.use_only(args.last)
      end

      def exclude_with_low_priority(*args)
        exclusions.add_with_low_priority(args.last)
      end

      def exclude?(example)
        exclusions.include_example?(example)
      end

      def include(*args)
        inclusions.add(args.last)
      end

      def include_only(*args)
        inclusions.use_only(args.last)
      end

      def include_with_low_priority(*args)
        inclusions.add_with_low_priority(args.last)
      end

      def include?(example)
        inclusions.include_example?(example)
      end
    end

    # @private
    class FilterRules
      PROC_HEX_NUMBER = /0x[0-9a-f]+@/
      PROJECT_DIR = File.expand_path('.')

      attr_accessor :opposite
      attr_reader :rules

      def self.build
        exclusions = ExclusionRules.new
        inclusions = InclusionRules.new
        exclusions.opposite = inclusions
        inclusions.opposite = exclusions
        [exclusions, inclusions]
      end

      def initialize(*args, &block)
        @rules = Hash.new(*args, &block)
      end

      def add(updated)
        @rules.merge!(updated).each_key { |k| opposite.delete(k) }
      end

      def add_with_low_priority(_updated)
        updated = _updated.merge(@rules)
        opposite.each_pair { |k,v| updated.delete(k) if updated[k] == v }
        @rules.replace(updated)
      end

      def use_only(updated)
        updated.each_key { |k| opposite.delete(k) }
        @rules.replace(updated)
      end

      def clear
        @rules.clear
      end

      def delete(key)
        @rules.delete(key)
      end

      def fetch(*args, &block)
        @rules.fetch(*args, &block)
      end

      def [](key)
        @rules[key]
      end

      def empty?
        rules.empty?
      end

      def each_pair(&block)
        @rules.each_pair(&block)
      end

      def description
        rules.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
      end
    end

    # @private
    class InclusionRules < FilterRules
      STANDALONE_FILTERS = [:locations, :full_description]

      def add_location(locations)
        replace_filters({ :locations => locations })
      end

      def add(*args)
        set_standalone_filter(*args) || super
      end

      def add_with_low_priority(*args)
        set_standalone_filter(*args) || super
      end

      def use(*args)
        set_standalone_filter(*args) || super
      end

      def include_example?(example)
        @rules.empty? ? true : example.any_apply?(@rules)
      end

      def standalone?
        is_standalone_filter?(@rules)
      end

    private

      def set_standalone_filter(updated)
        return true if standalone?

        if is_standalone_filter?(updated)
          replace_filters(updated)
          true
        end
      end

      def replace_filters(new_rules)
        @rules.replace(new_rules)
        opposite.clear
      end

      def is_standalone_filter?(rules)
        STANDALONE_FILTERS.any? { |key| rules.has_key?(key) }
      end
    end

    # @private
    class ExclusionRules < FilterRules
      CONDITIONAL_FILTERS = {
        :if     => lambda { |value| !value },
        :unless => lambda { |value| value }
      }.freeze

      def include_example?(example)
        example.any_apply?(@rules) || example.any_apply?(CONDITIONAL_FILTERS)
      end
    end
  end
end
