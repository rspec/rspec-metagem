module RSpec
  module Core
    # Each ExampleGroup class and Example instance owns an instance of
    # Metadata, which is Hash extended to support lazy evaluation of values
    # associated with keys that may or may not be used by any example or group.
    #
    # In addition to metadata that is used internally, this also stores
    # user-supplied metadata, e.g.
    #
    #     describe Something, :type => :ui do
    #       it "does something", :slow => true do
    #         # ...
    #       end
    #     end
    #
    # `:type => :ui` is stored in the Metadata owned by the example group, and
    # `:slow => true` is stored in the Metadata owned by the example. These can
    # then be used to select which examples are run using the `--tag` option on
    # the command line, or several methods on `Configuration` used to filter a
    # run (e.g. `filter_run_including`, `filter_run_excluding`, etc).
    #
    # @see Example#metadata
    # @see ExampleGroup.metadata
    # @see FilterManager
    # @see Configuration#filter_run_including
    # @see Configuration#filter_run_excluding
    class Metadata < Hash

      # @api private
      #
      # @param line [String] current code line
      # @return [String] relative path to line
      def self.relative_path(line)
        line = line.sub(File.expand_path("."), ".")
        line = line.sub(/\A([^:]+:\d+)$/, '\\1')
        return nil if line == '-e:1'
        line
      rescue SecurityError
        nil
      end

      # @private
      # Used internally to build a hash from an args array.
      # Symbols are converted into hash keys with a value of `true`.
      # This is done to support simple tagging using a symbol, rather
      # than needing to do `:symbol => true`.
      def self.build_hash_from(args)
        hash = args.last.is_a?(Hash) ? args.pop : {}

        while args.last.is_a?(Symbol)
          hash[args.pop] = true
        end

        hash
      end

      # @private
      module MetadataHash

        # @private
        # Supports lazy evaluation of some values. Extended by
        # ExampleMetadataHash and GroupMetadataHash, which get mixed in to
        # Metadata for ExampleGroups and Examples (respectively).
        def [](key)
          store_computed(key) unless has_key?(key)
          super
        end

        def fetch(key, *args)
          store_computed(key) unless has_key?(key)
          super
        end

        private

        def store_computed(key)
          case key
          when :location
            store(:location, location)
          when :file_path, :line_number
            file_path, line_number = file_and_line_number
            store(:file_path, file_path)
            store(:line_number, line_number)
          when :execution_result
            store(:execution_result, Example::ExecutionResult.new)
          when :describes, :described_class
            klass = described_class
            store(:described_class, klass)
            # TODO (2011-11-07 DC) deprecate :describes as a key
            store(:describes, klass)
          when :full_description
            store(:full_description, full_description)
          when :description
            store(:description, build_description_from(*self[:description_args]))
          when :description_args
            store(:description_args, [])
          end
        end

        def location
          "#{self[:file_path]}:#{self[:line_number]}"
        end

        def file_and_line_number
          first_caller_from_outside_rspec =~ /(.+?):(\d+)(|:\d+)/
          return [Metadata::relative_path($1), $2.to_i]
        end

        def first_caller_from_outside_rspec
          self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
        end

        def method_description_after_module?(parent_part, child_part)
          return false unless parent_part.is_a?(Module)
          child_part =~ /^(#|::|\.)/
        end

        def build_description_from(first_part = '', *parts)
          description, _ = parts.inject([first_part.to_s, first_part]) do |(desc, last_part), this_part|
            this_part = this_part.to_s
            this_part = (' ' + this_part) unless method_description_after_module?(last_part, this_part)
            [(desc + this_part), this_part]
          end

          description
        end
      end

      # Mixed in to Metadata for an Example (extends MetadataHash) to support
      # lazy evaluation of some values.
      module ExampleMetadataHash
        include MetadataHash

        # @private
        def described_class
          self[:example_group].described_class
        end

        # @private
        def full_description
          build_description_from(self[:example_group][:full_description], *self[:description_args])
        end
      end

      # Mixed in to Metadata for an ExampleGroup (extends MetadataHash) to
      # support lazy evaluation of some values.
      module GroupMetadataHash
        include MetadataHash

        # @private
        def described_class
          container_stack.each do |g|
            [:described_class, :describes].each do |key|
              if g.has_key?(key)
                value = g[key]
                return value unless value.nil?
              end
            end

            candidate = g[:description_args].first
            return candidate unless String === candidate || Symbol === candidate
          end

          nil
        end

        # @private
        def full_description
          build_description_from(*FlatMap.flat_map(container_stack.reverse) {|a| a[:description_args]})
        end

        # @private
        def container_stack
          @container_stack ||= begin
                                 groups = [group = self]
                                 while group.has_key?(:example_group)
                                   groups << group[:example_group]
                                   group = group[:example_group]
                                 end
                                 groups
                               end
        end
      end

      def initialize(parent_group_metadata=nil)
        if parent_group_metadata
          update(parent_group_metadata)
          store(:example_group, {:example_group => parent_group_metadata[:example_group].extend(GroupMetadataHash)}.extend(GroupMetadataHash))
        else
          store(:example_group, {}.extend(GroupMetadataHash))
        end

        yield self if block_given?
      end

      # @private
      def process(*args)
        user_metadata = args.last.is_a?(Hash) ? args.pop : {}
        ensure_valid_keys(user_metadata)

        self[:example_group].store(:description_args, args)
        self[:example_group].store(:caller, user_metadata.delete(:caller) || caller)

        update(user_metadata)
      end

      # @private
      def for_example(description, user_metadata)
        dup.extend(ExampleMetadataHash).configure_for_example(description, user_metadata)
      end

      protected

      def configure_for_example(description, user_metadata)
        store(:description_args, [description]) if description
        store(:caller, user_metadata.delete(:caller) || caller)
        update(user_metadata)
      end

      private

      RESERVED_KEYS = [
        :description,
        :example_group,
        :execution_result,
        :file_path,
        :full_description,
        :line_number,
        :location
      ]

      def ensure_valid_keys(user_metadata)
        RESERVED_KEYS.each do |key|
          if user_metadata.has_key?(key)
            raise <<-EOM
            #{"*"*50}
:#{key} is not allowed

RSpec reserves some hash keys for its own internal use,
including :#{key}, which is used on:

            #{CallerFilter.first_non_rspec_line}.

Here are all of RSpec's reserved hash keys:

            #{RESERVED_KEYS.join("\n  ")}
            #{"*"*50}
            EOM
          end
        end
      end

    end

    # Mixin that makes the including class imitate a hash for backwards
    # compatibility. The including class should use `attr_accessor` to
    # declare attributes and define a `deprecation_prefix` method.
    # @private
    module HashImitatable
      def self.included(klass)
        klass.extend ClassMethods
      end

      def to_h
        hash = extra_hash_attributes.dup

        self.class.hash_attribute_names.each do |name|
          hash[name] = __send__(name)
        end

        hash
      end

      (Hash.public_instance_methods - Object.public_instance_methods).each do |method_name|
        next if [:[], :[]=, :to_h].include?(method_name.to_sym)

        define_method(method_name) do |*args, &block|
          RSpec.deprecate("`#{deprecation_prefix}.#{method_name}`")

          hash = to_h
          self.class.hash_attribute_names.each do |name|
            hash.delete(name) unless instance_variable_defined?(:"@#{name}")
          end

          hash.__send__(method_name, *args, &block).tap do
            # apply mutations back to the object
            hash.each do |name, value|
              setter = :"#{name}="
              if respond_to?(setter)
                __send__(setter, value)
              else
                extra_hash_attributes[name] = value
              end
            end
          end
        end
      end

      def [](key)
        if respond_to?(key)
          RSpec.deprecate("`#{deprecation_prefix}[#{key.inspect}]`",
                            :replacement => "`#{deprecation_prefix}.#{key}`")
          __send__(key)
        else
          RSpec.deprecate("`#{deprecation_prefix}[#{key.inspect}]`")
          extra_hash_attributes[key]
        end
      end

      def []=(key, value)
        sender = :"#{key}="

        if respond_to?(sender)
          RSpec.deprecate("`#{deprecation_prefix}[#{key.inspect}] = `",
                            :replacement => "`#{deprecation_prefix}.#{key} =`")
          __send__(sender, value)
        else
          RSpec.deprecate("`#{deprecation_prefix}[#{key.inspect}] = `")
          extra_hash_attributes[key] = value
        end
      end

    private

      def extra_hash_attributes
        @extra_hash_attributes ||= {}
      end

      # @private
      module ClassMethods
        def hash_attribute_names
          @hash_attribute_names ||= []
        end

        def attr_accessor(*names)
          hash_attribute_names.concat(names)
          super
        end
      end
    end
  end
end
