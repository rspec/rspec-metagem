RSpec::Support.require_rspec_support 'recursive_const_methods'

module RSpec
  module Core
    # ExampleGroup and {Example} are the main structural elements of
    # rspec-core.  Consider this example:
    #
    #     describe Thing do
    #       it "does something" do
    #       end
    #     end
    #
    # The object returned by `describe Thing` is a subclass of ExampleGroup.
    # The object returned by `it "does something"` is an instance of Example,
    # which serves as a wrapper for an instance of the ExampleGroup in which it
    # is declared.
    #
    # Example group bodies (e.g. `describe` or `context` blocks) are evaluated
    # in the context of a new subclass of ExampleGroup. Individual examples are
    # evaluated in the context of an instance of the specific ExampleGroup subclass
    # to which they belong.
    #
    # Besides the class methods defined here, there are other interesting macros
    # defined in {Hooks}, {MemoizedHelpers::ClassMethods} and {SharedExampleGroup}.
    # There are additional instance methods available to your examples defined in
    # {MemoizedHelpers} and {Pending}.
    class ExampleGroup
      extend Hooks

      include MemoizedHelpers
      extend MemoizedHelpers::ClassMethods
      include Pending
      extend SharedExampleGroup

      unless respond_to?(:define_singleton_method)
        # @private
        def self.define_singleton_method(*a, &b)
          (class << self; self; end).__send__(:define_method, *a, &b)
        end
      end

      # @!group Metadata

      # The [Metadata](Metadata) object associated with this group.
      # @see Metadata
      def self.metadata
        @metadata if defined?(@metadata)
      end

      # @private
      # @return [Metadata] belonging to the parent of a nested {ExampleGroup}
      def self.superclass_metadata
        @superclass_metadata ||= superclass.respond_to?(:metadata) ? superclass.metadata : nil
      end

      # @private
      def self.delegate_to_metadata(*names)
        names.each do |name|
          define_singleton_method(name) { metadata.fetch(name) }
        end
      end

      delegate_to_metadata :described_class, :file_path, :location

      # @return [String] the current example group description
      def self.description
        description = metadata[:description]
        RSpec.configuration.format_docstrings_block.call(description)
      end

      # Returns the class or module passed to the `describe` method (or alias).
      # Returns nil if the subject is not a class or module.
      # @example
      #     describe Thing do
      #       it "does something" do
      #         described_class == Thing
      #       end
      #     end
      #
      #
      def described_class
        self.class.described_class
      end

      # @!endgroup

      # @!group Defining Examples

      # @private
      # @macro [attach] define_example_method
      #   @!scope class
      #   @param name [String]
      #   @param extra_options [Hash]
      #   @param implementation [Block]
      #   @yield [Example] the example object
      #   @example
      #     $1 do
      #     end
      #
      #     $1 "does something" do
      #     end
      #
      #     $1 "does something", :with => 'additional metadata' do
      #     end
      #
      #     $1 "does something" do |ex|
      #       # ex is the Example object that contains metadata about the example
      #     end
      def self.define_example_method(name, extra_options={})
        define_singleton_method(name) do |*all_args, &block|
          desc, *args = *all_args
          options = Metadata.build_hash_from(args)
          options.update(:skip => RSpec::Core::Pending::NOT_YET_IMPLEMENTED) unless block
          options.update(extra_options)

          # Metadata inheritance normally happens in `Example#initialize`,
          # but for `:pending` specifically we need it earlier.
          pending_metadata = options[:pending] || metadata[:pending]

          if pending_metadata
            options, block = ExampleGroup.pending_metadata_and_block_for(
              options.merge(:pending => pending_metadata),
              block
            )
          end

          examples << RSpec::Core::Example.new(self, desc, options, block)
          examples.last
        end
      end

      # Defines an example within a group.
      define_example_method :example
      # Defines an example within a group.
      # This is the primary API to define a code example.
      define_example_method :it
      # Defines an example within a group.
      # Useful for when your docstring does not read well off of `it`.
      # @example
      #  RSpec.describe MyClass do
      #    specify "#do_something is deprecated" do
      #      # ...
      #    end
      #  end
      define_example_method :specify

      # Shortcut to define an example with `:focus => true`
      # @see example
      define_example_method :focus,    :focus => true
      # Shortcut to define an example with `:focus => true`
      # @see example
      define_example_method :fexample, :focus => true
      # Shortcut to define an example with `:focus => true`
      # @see example
      define_example_method :fit,      :focus => true
      # Shortcut to define an example with `:focus => true`
      # @see example
      define_example_method :fspecify, :focus => true
      # Shortcut to define an example with `:skip => 'Temporarily skipped with xexample'`
      # @see example
      define_example_method :xexample, :skip => 'Temporarily skipped with xexample'
      # Shortcut to define an example with `:skip => 'Temporarily skipped with xit'`
      # @see example
      define_example_method :xit,      :skip => 'Temporarily skipped with xit'
      # Shortcut to define an example with `:skip => 'Temporarily skipped with xspecify'`
      # @see example
      define_example_method :xspecify, :skip => 'Temporarily skipped with xspecify'
      # Shortcut to define an example with `:skip => true`
      # @see example
      define_example_method :skip,     :skip => true
      # Shortcut to define an example with `:pending => true`
      # @see example
      define_example_method :pending,  :pending => true

      # @!endgroup

      # @!group Defining Example Groups

      # @private
      # @macro [attach] alias_example_group_to
      #   @!scope class
      #   @param name [String] The example group doc string
      #   @param metadata [Hash] Additional metadata to attach to the example group
      #   @yield The example group definition
      #
      #   Generates a subclass of this example group which inherits
      #   everything except the examples themselves.
      #
      #   @example
      #
      #     RSpec.describe "something" do # << This describe method is defined in
      #                                   # << RSpec::Core::DSL, included in the
      #                                   # << global namespace (optional)
      #       before do
      #         do_something_before
      #       end
      #
      #       let(:thing) { Thing.new }
      #
      #       $1 "attribute (of something)" do
      #         # examples in the group get the before hook
      #         # declared above, and can access `thing`
      #       end
      #     end
      #
      # @see DSL#describe
      def self.define_example_group_method(name, metadata={})
        define_singleton_method(name) do |*args, &example_group_block|
          thread_data = RSpec.thread_local_metadata
          top_level   = self == ExampleGroup

          if top_level
            if thread_data[:in_example_group]
              raise "Creating an isolated context from within a context is " \
                    "not allowed. Change `RSpec.#{name}` to `#{name}` or " \
                    "move this to a top-level scope."
            end

            thread_data[:in_example_group] = true
          end

          begin

            description = args.shift
            combined_metadata = metadata.dup
            combined_metadata.merge!(args.pop) if args.last.is_a? Hash
            args << combined_metadata

            subclass(self, description, args, &example_group_block).tap do |child|
              children << child
            end

          ensure
            thread_data.delete(:in_example_group) if top_level
          end
        end

        RSpec::Core::DSL.expose_example_group_alias(name)
      end

      define_example_group_method :example_group

      # An alias of `example_group`. Generally used when grouping
      # examples by a thing you are describing (e.g. an object, class or method).
      # @see example_group
      define_example_group_method :describe

      # An alias of `example_group`. Generally used when grouping examples
      # contextually (e.g. "with xyz", "when xyz" or "if xyz").
      # @see example_group
      define_example_group_method :context

      # Shortcut to temporarily make an example group skipped.
      # @see example_group
      define_example_group_method :xdescribe, :skip => "Temporarily skipped with xdescribe"

      # Shortcut to temporarily make an example group skipped.
      # @see example_group
      define_example_group_method :xcontext,  :skip => "Temporarily skipped with xcontext"

      # Shortcut to define an example group with `:focus => true`.
      # @see example_group
      define_example_group_method :fdescribe, :focus => true

      # Shortcut to define an example group with `:focus => true`.
      # @see example_group
      define_example_group_method :fcontext,  :focus => true

      # @!endgroup

      # @!group Including Shared Example Groups

      # @private
      # @macro [attach] define_nested_shared_group_method
      #   @!scope class
      #
      #   @see SharedExampleGroup
      def self.define_nested_shared_group_method(new_name, report_label="it should behave like")
        define_singleton_method(new_name) do |name, *args, &customization_block|
          # Pass :caller so the :location metadata is set properly...
          # otherwise, it'll be set to the next line because that's
          # the block's source_location.
          group = example_group("#{report_label} #{name}", :caller => caller) do
            find_and_eval_shared("examples", name, *args, &customization_block)
          end
          group.metadata[:shared_group_name] = name
          group
        end
      end

      # Generates a nested example group and includes the shared content
      # mapped to `name` in the nested group.
      define_nested_shared_group_method :it_behaves_like, "behaves like"
      # Generates a nested example group and includes the shared content
      # mapped to `name` in the nested group.
      define_nested_shared_group_method :it_should_behave_like

      # Includes shared content mapped to `name` directly in the group in which
      # it is declared, as opposed to `it_behaves_like`, which creates a nested
      # group. If given a block, that block is also eval'd in the current context.
      #
      # @see SharedExampleGroup
      def self.include_context(name, *args, &block)
        find_and_eval_shared("context", name, *args, &block)
      end

      # Includes shared content mapped to `name` directly in the group in which
      # it is declared, as opposed to `it_behaves_like`, which creates a nested
      # group. If given a block, that block is also eval'd in the current context.
      #
      # @see SharedExampleGroup
      def self.include_examples(name, *args, &block)
        find_and_eval_shared("examples", name, *args, &block)
      end

      # @private
      def self.find_and_eval_shared(label, name, *args, &customization_block)
        shared_block = RSpec.world.shared_example_group_registry.find(parent_groups, name)

        unless shared_block
          raise ArgumentError, "Could not find shared #{label} #{name.inspect}"
        end

        module_exec(*args, &shared_block)
        module_exec(&customization_block) if customization_block
      end

      # @!endgroup

      # @private
      def self.subclass(parent, description, args, &example_group_block)
        subclass = Class.new(parent)
        subclass.set_it_up(description, *args, &example_group_block)
        ExampleGroups.assign_const(subclass)
        subclass.module_exec(&example_group_block) if example_group_block

        # The LetDefinitions module must be included _after_ other modules
        # to ensure that it takes precedence when there are name collisions.
        # Thus, we delay including it until after the example group block
        # has been eval'd.
        MemoizedHelpers.define_helpers_on(subclass)

        subclass
      end

      # @private
      def self.set_it_up(*args, &example_group_block)
        # Ruby 1.9 has a bug that can lead to infinite recursion and a
        # SystemStackError if you include a module in a superclass after
        # including it in a subclass: https://gist.github.com/845896
        # To prevent this, we must include any modules in RSpec::Core::ExampleGroup
        # before users create example groups and have a chance to include
        # the same module in a subclass of RSpec::Core::ExampleGroup.
        # So we need to configure example groups here.
        ensure_example_groups_are_configured

        description = args.shift
        user_metadata = Metadata.build_hash_from(args)
        args.unshift(description)

        @metadata = Metadata::ExampleGroupHash.create(
          superclass_metadata, user_metadata, *args, &example_group_block
        )

        hooks.register_globals(self, RSpec.configuration.hooks)
        RSpec.world.configure_group(self)
      end

      # @private
      def self.examples
        @examples ||= []
      end

      # @private
      def self.filtered_examples
        RSpec.world.filtered_examples[self]
      end

      # @private
      def self.descendant_filtered_examples
        @descendant_filtered_examples ||= filtered_examples + children.inject([]) { |a, e| a + e.descendant_filtered_examples }
      end

      # @private
      def self.children
        @children ||= []
      end

      # @private
      def self.descendants
        @_descendants ||= [self] + children.inject([]) { |a, e| a + e.descendants }
      end

      ## @private
      def self.parent_groups
        @parent_groups ||= ancestors.select { |a| a < RSpec::Core::ExampleGroup }
      end

      # @private
      def self.top_level?
        @top_level ||= superclass == ExampleGroup
      end

      # @private
      def self.ensure_example_groups_are_configured
        unless defined?(@@example_groups_configured)
          RSpec.configuration.configure_mock_framework
          RSpec.configuration.configure_expectation_framework
          # rubocop:disable Style/ClassVars
          @@example_groups_configured = true
          # rubocop:enable Style/ClassVars
        end
      end

      # @private
      def self.before_context_ivars
        @before_context_ivars ||= {}
      end

      # @private
      def self.store_before_context_ivars(example_group_instance)
        return if example_group_instance.instance_variables.empty?

        example_group_instance.instance_variables.each do |ivar|
          before_context_ivars[ivar] = example_group_instance.instance_variable_get(ivar)
        end
      end

      # @private
      def self.run_before_context_hooks(example_group_instance)
        return if descendant_filtered_examples.empty?
        begin
          set_ivars(example_group_instance, superclass.before_context_ivars)

          ContextHookMemoizedHash::Before.isolate_for_context_hook(example_group_instance) do
            hooks.run(:before, :context, example_group_instance)
          end
        ensure
          store_before_context_ivars(example_group_instance)
        end
      end

      # @private
      def self.run_after_context_hooks(example_group_instance)
        return if descendant_filtered_examples.empty?
        set_ivars(example_group_instance, before_context_ivars)

        ContextHookMemoizedHash::After.isolate_for_context_hook(example_group_instance) do
          hooks.run(:after, :context, example_group_instance)
        end
      end

      # Runs all the examples in this group
      def self.run(reporter)
        if RSpec.world.wants_to_quit
          RSpec.world.clear_remaining_example_groups if top_level?
          return
        end
        reporter.example_group_started(self)

        begin
          run_before_context_hooks(new)
          result_for_this_group = run_examples(reporter)
          results_for_descendants = ordering_strategy.order(children).map { |child| child.run(reporter) }.all?
          result_for_this_group && results_for_descendants
        rescue Pending::SkipDeclaredInExample => ex
          for_filtered_examples(reporter) { |example| example.skip_with_exception(reporter, ex) }
        rescue Exception => ex
          RSpec.world.wants_to_quit = true if fail_fast?
          for_filtered_examples(reporter) { |example| example.fail_with_exception(reporter, ex) }
        ensure
          run_after_context_hooks(new)
          before_context_ivars.clear
          reporter.example_group_finished(self)
        end
      end

      # @private
      def self.ordering_strategy
        order = metadata.fetch(:order, :global)
        registry = RSpec.configuration.ordering_registry

        registry.fetch(order) do
          warn <<-WARNING.gsub(/^ +\|/, '')
            |WARNING: Ignoring unknown ordering specified using `:order => #{order.inspect}` metadata.
            |         Falling back to configured global ordering.
            |         Unrecognized ordering specified at: #{location}
          WARNING

          registry.fetch(:global)
        end
      end

      # @private
      def self.run_examples(reporter)
        ordering_strategy.order(filtered_examples).map do |example|
          next if RSpec.world.wants_to_quit
          instance = new
          set_ivars(instance, before_context_ivars)
          succeeded = example.run(instance, reporter)
          RSpec.world.wants_to_quit = true if fail_fast? && !succeeded
          succeeded
        end.all?
      end

      # @private
      def self.for_filtered_examples(reporter, &block)
        filtered_examples.each(&block)

        children.each do |child|
          reporter.example_group_started(child)
          child.for_filtered_examples(reporter, &block)
          reporter.example_group_finished(child)
        end
        false
      end

      # @private
      def self.fail_fast?
        RSpec.configuration.fail_fast?
      end

      # @private
      def self.any_apply?(filters)
        MetadataFilter.any_apply?(filters, metadata)
      end

      # @private
      def self.all_apply?(filters)
        MetadataFilter.all_apply?(filters, metadata)
      end

      # @private
      def self.declaration_line_numbers
        @declaration_line_numbers ||= [metadata[:line_number]] +
          examples.map { |e| e.metadata[:line_number] } +
          children.inject([]) { |a, e| a + e.declaration_line_numbers }
      end

      # @private
      def self.top_level_description
        parent_groups.last.description
      end

      # @private
      def self.set_ivars(instance, ivars)
        ivars.each { |name, value| instance.instance_variable_set(name, value) }
      end

      # @private
      def self.pending_metadata_and_block_for(options, block)
        if String === options[:pending]
          reason = options[:pending]
        else
          options[:pending] = true
          reason = RSpec::Core::Pending::NO_REASON_GIVEN
        end

        # Assign :caller so that the callback's source_location isn't used
        # as the example location.
        options[:caller] ||= Metadata.backtrace_from(block)

        # This will fail if no block is provided, which is effectively the
        # same as failing the example so it will be marked correctly as
        # pending.
        callback = Proc.new do
          pending(reason)
          instance_exec(&block)
        end

        return options, callback
      end
    end

    # @private
    # Unnamed example group used by `SuiteHookContext`.
    class AnonymousExampleGroup < ExampleGroup
      def self.metadata
        {}
      end
    end
  end

  # @private
  #
  # Namespace for the example group subclasses generated by top-level `describe`.
  module ExampleGroups
    extend Support::RecursiveConstMethods

    def self.assign_const(group)
      base_name   = base_name_for(group)
      const_scope = constant_scope_for(group)
      name        = disambiguate(base_name, const_scope)

      const_scope.const_set(name, group)
    end

    def self.constant_scope_for(group)
      const_scope = group.superclass
      const_scope = self if const_scope == ::RSpec::Core::ExampleGroup
      const_scope
    end

    def self.base_name_for(group)
      return "Anonymous" if group.description.empty?

      # convert to CamelCase
      name = ' ' + group.description
      name.gsub!(/[^0-9a-zA-Z]+([0-9a-zA-Z])/) { Regexp.last_match[1].upcase }

      name.lstrip!         # Remove leading whitespace
      name.gsub!(/\W/, '') # JRuby, RBX and others don't like non-ascii in const names

      # Ruby requires first const letter to be A-Z. Use `Nested`
      # as necessary to enforce that.
      name.gsub!(/\A([^A-Z]|\z)/, 'Nested\1')

      name
    end

    def self.disambiguate(name, const_scope)
      return name unless const_defined_on?(const_scope, name)

      # Add a trailing number if needed to disambiguate from an existing constant.
      name << "_2"
      name.next! while const_defined_on?(const_scope, name)
      name
    end
  end
end
