require 'rspec/core/advice'
require 'rspec/core/example_group_subject'
require 'rspec/core/metadata'

module Rspec
  module Core
    class ExampleGroup
      extend Advice
      include ExampleGroupSubject

      attr_accessor :running_example, :reporter

      def self.inherited(klass)
        super
        Rspec::Core.configuration.autorun!
        Rspec::Core.world.behaviours << klass
      end

      def self.extended_modules #:nodoc:
        ancestors = class << self; ancestors end
        ancestors.select { |mod| mod.class == Module } - [ Object, Kernel ]
      end

      def self.example(desc=nil, options={}, &block)
        examples << Rspec::Core::Example.new(self, desc, options.update(:caller => caller[0]), block)
      end

      def self.alias_example_to(new_alias, extra_options={})
        new_alias = <<-END_RUBY
                      def self.#{new_alias}(desc=nil, options={}, &block)
                        updated_options = options.update(:caller => caller[0])
                        updated_options.update(#{extra_options.inspect})
                        block = nil if updated_options[:pending] == true || updated_options[:disabled] == true
                        examples << Rspec::Core::Example.new(self, desc, updated_options, block)
                      end
                    END_RUBY
        module_eval(new_alias, __FILE__, __LINE__)
      end

      alias_example_to :it
      alias_example_to :specify
      alias_example_to :focused, :focused => true
      alias_example_to :disabled, :disabled => true
      alias_example_to :pending, :pending => true

      def self.it_should_behave_like(*names)
        Rspec::Core.world.shared_behaviours.each do |name, block|
          module_eval(&block) if names.include?(name)
        end
      end

      def self.examples
        @_examples ||= []
      end

      def self.examples_to_run
        @_examples_to_run ||= []
      end

      def self.set_it_up(*args)
        @metadata = Rspec::Core::Metadata.process(self.superclass.metadata, *args)

        Rspec::Core.configuration.find_modules(self).each do |include_or_extend, mod, opts|
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

      def self.name(friendly=true)
        friendly ? metadata[:behaviour][:name] : super
      end

      def self.describes
        metadata[:behaviour][:describes]
      end

      def self.described_class
        describes || description
      end

      def self.description
        metadata[:behaviour][:description]
      end

      def self.file_path
        metadata[:behaviour][:file_path]
      end

      def self.describe(*args, &behaviour_block)
        raise(ArgumentError, "No arguments given.  You must a least supply a type or description") if args.empty? 
        raise(ArgumentError, "You must supply a block when calling describe") if behaviour_block.nil?

        # TODO: Pull out the below into a metadata object, that we can defer the subclassing if necessary
        # describe 'foo', :shared => true will need this to be completed first
        subclass('NestedLevel') do
          args << {} unless args.last.is_a?(Hash)
          args.last.update(:behaviour_block => behaviour_block, :caller => caller(2))
          set_it_up(*args)
          module_eval(&behaviour_block)
        end
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

      def self.eval_before_alls(running_behaviour)
        superclass.before_all_ivars.each { |ivar, val| running_behaviour.instance_variable_set(ivar, val) }
        Rspec::Core.configuration.find_advice(:before, :all, self).each { |blk| running_behaviour.instance_eval(&blk) }

        before_alls.each { |blk| running_behaviour.instance_eval(&blk) }
        running_behaviour.instance_variables.each { |ivar| before_all_ivars[ivar] = running_behaviour.instance_variable_get(ivar) }
      end

      def self.eval_before_eachs(running_behaviour)
        Rspec::Core.configuration.find_advice(:before, :each, self).each { |blk| running_behaviour.instance_eval(&blk) }
        before_ancestors.each { |ancestor| ancestor.before_eachs.each { |blk| running_behaviour.instance_eval(&blk) } }
      end

      def self.eval_after_alls(running_behaviour)
        after_alls.each { |blk| running_behaviour.instance_eval(&blk) }
        Rspec::Core.configuration.find_advice(:after, :all, self).each { |blk| running_behaviour.instance_eval(&blk) }
        before_all_ivars.keys.each { |ivar| before_all_ivars[ivar] = running_behaviour.instance_variable_get(ivar) }
      end

      def self.eval_after_eachs(running_behaviour)
        after_ancestors.each { |ancestor| ancestor.after_eachs.each { |blk| running_behaviour.instance_eval(&blk) } }
        Rspec::Core.configuration.find_advice(:after, :each, self).each { |blk| running_behaviour.instance_eval(&blk) }
      end

      def self.run(reporter)
        example_world = new
        reporter.add_behaviour(self)
        eval_before_alls(example_world)
        success = run_examples(example_world, reporter)
        eval_after_alls(example_world)

        success
      end

      # Runs all examples, returning true only if all of them pass
      def self.run_examples(example_world, reporter)
        examples_to_run.map do |ex| 
          result = ex.run(example_world) 
          example_world.__reset__
          before_all_ivars.each { |k, v| example_world.instance_variable_set(k, v) } 
          result
        end.all?
      end


      def self.subclass(base_name, &body) # :nodoc:
        @_sub_class_count ||= 0
        @_sub_class_count += 1
        klass = Class.new(self)
        class_name = "#{base_name}_#{@_sub_class_count}"
        const_set(class_name, klass)
        klass.instance_eval(&body)
        klass
      end

      def self.to_s
        self == Rspec::Core::ExampleGroup ? 'Rspec::Core::ExampleGroup' : name
      end

      def self.let(name, &block)
        # Should we block defining method names already defined?
        define_method(name) do
          assignments[name] ||= instance_eval(&block)
        end
      end

      def assignments
        @assignments ||= {}
      end

      def __reset__
        instance_variables.each { |ivar| remove_instance_variable(ivar) }
        assignments.clear
      end

    end
  end
end
