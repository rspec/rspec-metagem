require 'rspec/core/hooks'
require 'rspec/core/example_group_subject'
require 'rspec/core/let'
require 'rspec/core/metadata'

module Rspec
  module Core
    class ExampleGroup
      extend  Hooks
      include ExampleGroupSubject
      include Let

      attr_accessor :running_example

      def self.inherited(klass)
        Rspec::Core::Runner.autorun
        Rspec::Core.world.example_groups << klass
      end

      def self.extended_modules #:nodoc:
        ancestors = class << self; ancestors end
        ancestors.select { |mod| mod.class == Module } - [ Object, Kernel ]
      end

      def self.example(desc=nil, options={}, &block)
        options.update(:pending => true) unless block
        options.update(:caller => caller)
        examples << Rspec::Core::Example.new(self, desc, options, block)
      end

      def self.alias_example_to(new_alias, extra_options={})
        new_alias = <<-END_RUBY
                      def self.#{new_alias}(desc=nil, options={}, &block)
                        updated_options = options.update(:caller => caller)
                        updated_options.update(:pending => true) unless block
                        updated_options.update(#{extra_options.inspect})
                        examples << Rspec::Core::Example.new(self, desc, updated_options, block)
                      end
                    END_RUBY
        module_eval(new_alias, __FILE__, __LINE__)
      end

      alias_example_to :it
      alias_example_to :specify
      alias_example_to :focused, :focused => true
      alias_example_to :pending, :pending => true

      def self.it_should_behave_like(*names)
        Rspec::Core.world.shared_example_groups.each do |name, block|
          module_eval(&block) if names.include?(name)
        end
      end

      def self.examples
        @_examples ||= []
      end

      def self.examples_to_run
        @_examples_to_run ||= []
      end

      def self.superclass_metadata
        self.superclass.respond_to?(:metadata) ? self.superclass.metadata : nil
      end

      def self.configuration
        @configuration
      end

      def self.set_it_up(*args)
        @configuration = args.shift
        @metadata = Rspec::Core::Metadata.new(superclass_metadata).process(*args)

        configuration.find_modules(self).each do |include_or_extend, mod, opts|
          if include_or_extend == :extend
            send(:extend, mod) unless extended_modules.include?(mod)
          else
            send(:include, mod) unless included_modules.include?(mod)
          end
        end
      end

      def self.metadata
        @metadata 
      end

      def self.display_name
        metadata[:example_group][:description]
      end

      def self.description
        metadata[:example_group][:description]
      end

      def self.describes
        metadata[:example_group][:describes]
      end

      def self.file_path
        metadata[:example_group][:file_path]
      end

      def self.describe(*args, &example_group_block)
        raise(ArgumentError, "No arguments given.  You must a least supply a type or description") if args.empty? 
        raise(ArgumentError, "You must supply a block when calling describe") if example_group_block.nil?
        @_subclass_count ||= 0
        @_subclass_count += 1
        const_set(
          "NestedLevel_#{@_subclass_count}",
          _build(Class.new(self), caller, args, &example_group_block)
        )
      end

      def self.create(*args, &example_group_block)
        _build(dup, caller, args, &example_group_block)
      end

      def self._build(klass, given_caller, args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update(:example_group_block => example_group_block, :caller => given_caller)
        args.unshift Rspec.configuration unless args.first.is_a?(Rspec::Core::Configuration)
        klass.set_it_up(*args) 
        klass.module_eval(&example_group_block) if example_group_block
        klass
      end

      class << self
        alias_method :context, :describe
      end

      def self.ancestors(superclass_last=false)
        classes = []
        current_class = self

        while current_class < Rspec::Core::ExampleGroup
          superclass_last ? classes << current_class : classes.unshift(current_class)
          current_class = current_class.superclass
        end

        classes
      end

      def self.before_ancestors
        @_before_ancestors ||= ancestors 
      end

      def self.after_ancestors
        @_after_ancestors ||= ancestors(true)
      end

      def self.before_all_ivars
        @before_all_ivars ||= {}
      end

      def self.eval_before_alls(running_example)
        if superclass.respond_to?(:before_all_ivars)
          superclass.before_all_ivars.each { |ivar, val| running_example.instance_variable_set(ivar, val) }
        end
        configuration.find_hook(:before, :all, self).each { |blk| running_example.instance_eval(&blk) }

        before_alls.each { |blk| running_example.instance_eval(&blk) }
        running_example.instance_variables.each { |ivar| before_all_ivars[ivar] = running_example.instance_variable_get(ivar) }
      end

      def self.eval_before_eachs(running_example)
        configuration.find_hook(:before, :each, self).each { |blk| running_example.instance_eval(&blk) }
        before_ancestors.each { |ancestor| ancestor.before_eachs.each { |blk| running_example.instance_eval(&blk) } }
      end

      def self.eval_after_alls(running_example)
        after_alls.each { |blk| running_example.instance_eval(&blk) }
        configuration.find_hook(:after, :all, self).each { |blk| running_example.instance_eval(&blk) }
        before_all_ivars.keys.each { |ivar| before_all_ivars[ivar] = running_example.instance_variable_get(ivar) }
      end

      def self.eval_after_eachs(running_example)
        after_ancestors.each { |ancestor| ancestor.after_eachs.each { |blk| running_example.instance_eval(&blk) } }
        configuration.find_hook(:after, :each, self).each { |blk| running_example.instance_eval(&blk) }
      end

      def self.run(reporter)
        example_group_instance = new
        reporter.add_example_group(self)
        eval_before_alls(example_group_instance)
        success = run_examples(example_group_instance, reporter)
        eval_after_alls(example_group_instance)

        success
      end

      # Runs all examples, returning true only if all of them pass
      def self.run_examples(example_world, reporter)
        examples_to_run.map do |ex| 
          result = ex.run(example_world, reporter) 
          example_world.__reset__
          before_all_ivars.each { |k, v| example_world.instance_variable_set(k, v) } 
          result
        end.all?
      end

      def self.to_s
        self == Rspec::Core::ExampleGroup ? 'Rspec::Core::ExampleGroup' : name
      end

      def self.all_apply?(filters)
        metadata.all_apply?(filters)
      end

      def described_class
        self.class.describes
      end

      def __reset__
        instance_variables.each { |ivar| remove_instance_variable(ivar) }
        __memoized.clear
      end

    end
  end
end
