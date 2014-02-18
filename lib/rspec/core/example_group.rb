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
    class ExampleGroup
      extend  Hooks

      include MemoizedHelpers
      include Pending
      extend SharedExampleGroup

      # @private
      def self.world
        RSpec.world
      end

      # @private
      def self.register
        world.register(self)
      end

      class << self
        # @private
        def self.delegate_to_metadata(*names)
          names.each do |name|
            define_method name do
              metadata[:example_group][name]
            end
          end
        end

        def description
          description = metadata[:example_group][:description]
          RSpec.configuration.format_docstrings_block.call(description)
        end

        delegate_to_metadata :described_class, :file_path
        alias_method :display_name, :description
        # @private
        alias_method :describes, :described_class

        # @private
        # @macro [attach] define_example_method
        #   @param [String] name
        #   @param [Hash] extra_options
        #   @param [Block] implementation
        #   @yield [Example] the example object
        def self.define_example_method(name, extra_options={})
          define_method(name) do |*all_args, &block|
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

        def pending_metadata_and_block_for(options, block)
          if String === options[:pending]
            reason = options[:pending]
          else
            options[:pending] = true
            reason = RSpec::Core::Pending::NO_REASON_GIVEN
          end

          # This will fail if no block is provided, which is effectively the
          # same as failing the example so it will be marked correctly as
          # pending.
          callback = Proc.new { pending(reason); instance_exec(&block) }

          return options, callback
        end

        # Defines an example within a group.
        # @example
        #   example do
        #   end
        #
        #   example "does something" do
        #   end
        #
        #   example "does something", :with => 'additional metadata' do
        #   end
        #
        #   example "does something" do |ex|
        #     # ex is the Example object that evals this block
        #   end
        define_example_method :example
        # Defines an example within a group.
        # @example
        define_example_method :it
        # Defines an example within a group.
        # This is here primarily for backward compatibility with early versions
        # of RSpec which used `context` and `specify` instead of `describe` and
        # `it`.
        define_example_method :specify

        # Shortcut to define an example with `:focus` => true
        # @see example
        define_example_method :focus,   :focused => true, :focus => true
        # Shortcut to define an example with `:focus` => true
        # @see example
        define_example_method :focused, :focused => true, :focus => true
        # Shortcut to define an example with `:focus` => true
        # @see example
        define_example_method :fit,     :focused => true, :focus => true

        # Shortcut to define an example with :skip => 'Temporarily skipped with xexample'
        # @see example
        define_example_method :xexample, :skip => 'Temporarily skipped with xexample'
        # Shortcut to define an example with :skip => 'Temporarily skipped with xit'
        # @see example
        define_example_method :xit,      :skip => 'Temporarily skipped with xit'
        # Shortcut to define an example with :skip => 'Temporarily skipped with xspecify'
        # @see example
        define_example_method :xspecify, :skip => 'Temporarily skipped with xspecify'
        # Shortcut to define an example with :skip => true
        # @see example
        define_example_method :skip,     :skip => true
        # Shortcut to define an example with :pending => true
        # @see example
        define_example_method :pending,  :pending => true

        # Works like `alias_method :name, :example` with the added benefit of
        # assigning default metadata to the generated example.
        #
        # @note Use with caution. This extends the language used in your
        #   specs, but does not add any additional documentation.  We use this
        #   in rspec to define methods like `focus` and `xit`, but we also add
        #   docs for those methods.
        def alias_example_to name, extra={}
          (class << self; self; end).define_example_method name, extra
        end

        # @private
        # @macro [attach] alias_example_group_to
        #   @scope class
        #   @param [String] docstring The example group doc string
        #   @param [Hash] metadata Additional metadata to attach to the example group
        #   @yield The example group definition
        def alias_example_group_to(name, metadata={})
          (class << self; self; end).__send__(:define_method, name) do |*args, &block|
            combined_metadata = metadata.dup
            combined_metadata.merge!(args.pop) if args.last.is_a? Hash
            args << combined_metadata
            example_group(*args, &block)
          end

          RSpec::Core::DSL.expose_example_group_alias(name)
        end

        # @private
        # @macro [attach] define_nested_shared_group_method
        #
        #   @see SharedExampleGroup
        def self.define_nested_shared_group_method(new_name, report_label="it should behave like")
          define_method(new_name) do |name, *args, &customization_block|
            group = example_group("#{report_label} #{name}") do
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

        # Works like `alias_method :name, :it_behaves_like` with the added
        # benefit of assigning default metadata to the generated example.
        #
        # @note Use with caution. This extends the language used in your
        #   specs, but does not add any additional documentation.  We use this
        #   in rspec to define `it_should_behave_like` (for backward
        #   compatibility), but we also add docs for that method.
        def alias_it_behaves_like_to name, *args, &block
          (class << self; self; end).define_nested_shared_group_method name, *args, &block
        end
      end

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
        raise ArgumentError, "Could not find shared #{label} #{name.inspect}" unless
          shared_block = shared_example_groups[name]

        module_exec(*args, &shared_block)
        module_eval(&customization_block) if customization_block
      end

      # @private
      def self.examples
        @examples ||= []
      end

      # @private
      def self.filtered_examples
        world.filtered_examples[self]
      end

      # @private
      def self.descendant_filtered_examples
        @descendant_filtered_examples ||= filtered_examples + children.inject([]){|l,c| l + c.descendant_filtered_examples}
      end

      # The [Metadata](Metadata) object associated with this group.
      # @see Metadata
      def self.metadata
        @metadata if defined?(@metadata)
      end

      # @private
      # @return [Metadata] belonging to the parent of a nested {ExampleGroup}
      def self.superclass_metadata
        @superclass_metadata ||= self.superclass.respond_to?(:metadata) ? self.superclass.metadata : nil
      end

      # Generates a subclass of this example group which inherits
      # everything except the examples themselves.
      #
      # ## Examples
      #
      #     describe "something" do # << This describe method is defined in
      #                             # << RSpec::Core::DSL, included in the
      #                             # << global namespace (optional)
      #       before do
      #         do_something_before
      #       end
      #
      #       let(:thing) { Thing.new }
      #
      #       describe "attribute (of something)" do
      #         # examples in the group get the before hook
      #         # declared above, and can access `thing`
      #       end
      #     end
      #
      # @see DSL#describe
      def self.example_group(*args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update(:example_group_block => example_group_block)

        child = subclass(self, args, &example_group_block)
        children << child
        child
      end

      # An alias of `example_group`. Generally used when grouping
      # examples by a thing you are describing (e.g. an object, class or method).
      # @see example_group
      alias_example_group_to :describe

      # An alias of `example_group`. Generally used when grouping examples
      # contextually.
      # @see example_group
      alias_example_group_to :context

      # Shortcut to temporarily make an example group pending.
      # @see example_group
      alias_example_group_to :xdescribe, :skip => "Temporarily skipped with xdescribe"

      # Shortcut to temporarily make an example group pending.
      # @see example_group
      alias_example_group_to :xcontext,  :skip => "Temporarily skipped with xcontext"

      # Shortcut to define an example group with `:focus` => true
      # @see example_group
      alias_example_group_to :fdescribe, :focus => true, :focused => true

      # Shortcut to define an example group with `:focus` => true
      # @see example_group
      alias_example_group_to :fcontext,  :focus => true, :focused => true

      # @private
      def self.subclass(parent, args, &example_group_block)
        subclass = Class.new(parent)
        subclass.set_it_up(*args)
        ExampleGroups.assign_const(subclass)
        subclass.module_eval(&example_group_block) if example_group_block

        # The LetDefinitions module must be included _after_ other modules
        # to ensure that it takes precendence when there are name collisions.
        # Thus, we delay including it until after the example group block
        # has been eval'd.
        MemoizedHelpers.define_helpers_on(subclass)

        subclass
      end

      # @private
      def self.children
        @children ||= []
      end

      # @private
      def self.descendants
        @_descendants ||= [self] + children.inject([]) {|list, c| list + c.descendants}
      end

      ## @private
      def self.parent_groups
        @parent_groups ||= ancestors.select {|a| a < RSpec::Core::ExampleGroup}
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
          @@example_groups_configured = true
        end
      end

      # @private
      def self.set_it_up(*args)
        # Ruby 1.9 has a bug that can lead to infinite recursion and a
        # SystemStackError if you include a module in a superclass after
        # including it in a subclass: https://gist.github.com/845896
        # To prevent this, we must include any modules in RSpec::Core::ExampleGroup
        # before users create example groups and have a chance to include
        # the same module in a subclass of RSpec::Core::ExampleGroup.
        # So we need to configure example groups here.
        ensure_example_groups_are_configured

        symbol_description = args.shift if args.first.is_a?(Symbol)
        args << Metadata.build_hash_from(args)
        args.unshift(symbol_description) if symbol_description
        @metadata = RSpec::Core::Metadata.new(superclass_metadata).process(*args)
        @order = nil
        hooks.register_globals(self, RSpec.configuration.hooks)
        world.configure_group(self)
      end

      # @private
      def self.before_all_ivars
        @before_all_ivars ||= {}
      end

      # @private
      def self.store_before_all_ivars(example_group_instance)
        return if example_group_instance.instance_variables.empty?

        example_group_instance.instance_variables.each { |ivar|
          before_all_ivars[ivar] = example_group_instance.instance_variable_get(ivar)
        }
      end

      # @private
      def self.run_before_all_hooks(example_group_instance)
        return if descendant_filtered_examples.empty?
        begin
          set_ivars(example_group_instance, superclass.before_all_ivars)

          AllHookMemoizedHash::Before.isolate_for_all_hook(example_group_instance) do
            hooks.run(:before, :all, example_group_instance)
          end
        ensure
          store_before_all_ivars(example_group_instance)
        end
      end

      # @private
      def self.run_after_all_hooks(example_group_instance)
        return if descendant_filtered_examples.empty?
        set_ivars(example_group_instance, before_all_ivars)

        AllHookMemoizedHash::After.isolate_for_all_hook(example_group_instance) do
          hooks.run(:after, :all, example_group_instance)
        end
      end

      # Runs all the examples in this group
      def self.run(reporter)
        if RSpec.wants_to_quit
          RSpec.clear_remaining_example_groups if top_level?
          return
        end
        reporter.example_group_started(self)

        begin
          run_before_all_hooks(new)
          result_for_this_group = run_examples(reporter)
          results_for_descendants = ordering_strategy.order(children).map { |child| child.run(reporter) }.all?
          result_for_this_group && results_for_descendants
        rescue Pending::SkipDeclaredInExample => ex
          for_filtered_examples(reporter) {|example| example.skip_with_exception(reporter, ex) }
        rescue Exception => ex
          RSpec.wants_to_quit = true if fail_fast?
          for_filtered_examples(reporter) {|example| example.fail_with_exception(reporter, ex) }
        ensure
          run_after_all_hooks(new)
          before_all_ivars.clear
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
            |         Unrecognized ordering specified at: #{metadata[:example_group][:location]}
          WARNING

          registry.fetch(:global)
        end
      end

      # @private
      def self.run_examples(reporter)
        ordering_strategy.order(filtered_examples).map do |example|
          next if RSpec.wants_to_quit
          instance = new
          set_ivars(instance, before_all_ivars)
          succeeded = example.run(instance, reporter)
          RSpec.wants_to_quit = true if fail_fast? && !succeeded
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
        metadata.any_apply?(filters)
      end

      # @private
      def self.all_apply?(filters)
        metadata.all_apply?(filters)
      end

      # @private
      def self.declaration_line_numbers
        @declaration_line_numbers ||= [metadata[:example_group][:line_number]] +
          examples.collect {|e| e.metadata[:line_number]} +
          children.inject([]) {|l,c| l + c.declaration_line_numbers}
      end

      # @private
      def self.top_level_description
        parent_groups.last.description
      end

      # @private
      def self.set_ivars(instance, ivars)
        ivars.each {|name, value| instance.instance_variable_set(name, value)}
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

      # @private
      # instance_evals the block, capturing and reporting an exception if
      # raised
      def instance_exec_with_rescue(example, context = nil, &hook)
        begin
          instance_exec(example, &hook)
        rescue Exception => e
          if RSpec.current_example
            RSpec.current_example.set_exception(e, context)
          else
            raise
          end
        end
      end
    end
  end

  # Namespace for the example group subclasses generated by top-level `describe`.
  module ExampleGroups
    def self.assign_const(group)
      base_name   = base_name_for(group)
      const_scope = constant_scope_for(group)
      name        = disambiguate(base_name, const_scope)

      const_scope.const_set(name, group)
    end

    def self.constant_scope_for(group)
      const_scope = group.superclass
      const_scope = self if const_scope == Core::ExampleGroup
      const_scope
    end

    def self.base_name_for(group)
      return "Anonymous" if group.description.empty?

      # convert to CamelCase
      name = ' ' + group.description
      name.gsub!(/[^0-9a-zA-Z]+([0-9a-zA-Z])/) { $1.upcase }

      name.lstrip!         # Remove leading whitespace
      name.gsub!(/\W/, '') # JRuby, RBX and others don't like non-ascii in const names

      # Ruby requires first const letter to be A-Z. Use `Nested`
      # as necessary to enforce that.
      name.gsub!(/\A([^A-Z]|\z)/, 'Nested\1')

      name
    end

    def self.disambiguate(name, const_scope)
      return name unless const_scope.const_defined?(name)

      # Add a trailing number if needed to disambiguate from an existing constant.
      name << "_2"
      name.next! while const_scope.const_defined?(name)
      name
    end
  end
end

