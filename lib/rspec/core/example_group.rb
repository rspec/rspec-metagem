module RSpec
  module Core
    class ExampleGroup
      extend  Hooks
      include Subject
      include Let
      include Pending

      attr_accessor :example

      def running_example
        RSpec.deprecate('running_example', 'example')
        example
      end

      def self.world
        RSpec.world
      end

      def self.inherited(klass)
        RSpec::Core::Runner.autorun
        world.example_groups << klass if klass.superclass == ExampleGroup
      end

      class << self
        def self.delegate_to_metadata(*names)
          names.each do |name|
            define_method name do
              metadata[:example_group][name]
            end
          end
        end

        delegate_to_metadata :description, :describes, :file_path
        alias_method :display_name, :description
      end

      def self.define_example_method(name, extra_options={})
        module_eval(<<-END_RUBY, __FILE__, __LINE__)
          def self.#{name}(desc=nil, options={}, &block)
            options.update(:pending => true) unless block
            options.update(:caller => caller)
            options.update(#{extra_options.inspect})
            examples << RSpec::Core::Example.new(self, desc, options, block)
            examples.last
          end
        END_RUBY
      end

      define_example_method :example

      class << self
        alias_method :alias_example_to, :define_example_method
      end

      alias_example_to :it
      alias_example_to :its, :attribute_of_subject => true
      alias_example_to :specify
      alias_example_to :focused, :focused => true
      alias_example_to :pending, :pending => true

      def self.it_should_behave_like(*names)
        names.each do |name|
          begin
            module_eval &RSpec.world.shared_example_groups[name]
          rescue ArgumentError
            raise "Could not find shared example group named #{name.inspect}"
          end
        end
      end

      def self.examples
        @examples ||= []
      end

      def self.filtered_examples
        world.filtered_examples[self]
      end

      def self.descendant_filtered_examples
        filtered_examples + children.collect{|c| c.descendant_filtered_examples}
      end

      def self.metadata
        @metadata 
      end

      def self.superclass_metadata
        self.superclass.respond_to?(:metadata) ? self.superclass.metadata : nil
      end

      def self.describe(*args, &example_group_block)
        @_subclass_count ||= 0
        @_subclass_count += 1
        args << {} unless args.last.is_a?(Hash)
        args.last.update(:example_group_block => example_group_block)
        args.last.update(:caller => caller)

        # TODO 2010-05-05: Because we don't know if const_set is thread-safe
        child = const_set(
          "Nested_#{@_subclass_count}",
          subclass(self, args, &example_group_block)
        )
        children << child
        child
      end

      class << self
        alias_method :context, :describe
      end

      def self.subclass(parent, args, &example_group_block)
        subclass = Class.new(parent)
        subclass.set_it_up(*args) 
        subclass.module_eval(&example_group_block) if example_group_block
        subclass
      end

      def self.children
        @children ||= []
      end

      def self.descendants
        [self] + children.collect {|c| c.descendants}.flatten
      end

      def self.ancestors
        @_ancestors ||= super().select {|a| a < RSpec::Core::ExampleGroup}
      end

      def self.set_it_up(*args)
        @metadata = RSpec::Core::Metadata.new(superclass_metadata).process(*args)

        world.find_modules(self).each do |include_or_extend, mod, opts|
          send(include_or_extend, mod) unless mixins[include_or_extend].include?(mod)
        end
      end

      def self.before_all_ivars
        @before_all_ivars ||= {}
      end

      def self.eval_before_alls(running_example)
        return if descendant_filtered_examples.empty?
        superclass.before_all_ivars.each { |ivar, val| running_example.instance_variable_set(ivar, val) }
        world.run_hook(:before, :all, self, running_example)

        until before_alls.empty?
          running_example.instance_eval &before_alls.shift
        end
        running_example.instance_variables.each { |ivar| before_all_ivars[ivar] = running_example.instance_variable_get(ivar) }
      end

      def self.eval_before_eachs(running_example)
        world.run_hook(:before, :each, self, running_example)
        ancestors.reverse.each { |ancestor| ancestor.before_eachs.each { |blk| running_example.instance_eval(&blk) } }
      end

      def self.eval_after_eachs(running_example)
        ancestors.each { |ancestor| ancestor.after_eachs.reverse.each { |blk| running_example.instance_eval(&blk) } }
        world.run_hook(:after, :each, self, running_example)
      end

      def self.eval_after_alls(running_example)
        return if descendant_filtered_examples.empty?
        before_all_ivars.each { |ivar, val| running_example.instance_variable_set(ivar, val) }
        ancestors.each do |ancestor|
          until ancestor.after_alls.empty?
            running_example.instance_eval &ancestor.after_alls.pop
          end
        end
        world.run_hook(:after, :all, self, running_example)
      end

      def self.run(reporter)
        example_group_instance = new
        reporter.add_example_group(self)
        begin
          eval_before_alls(example_group_instance)
          run_examples(example_group_instance, reporter) && 
            children.map {|child| child.run(reporter)}.all?
        ensure
          eval_after_alls(example_group_instance)
        end
      end

      def self.run_examples(instance, reporter)
        filtered_examples.map do |example|
          begin
            set_ivars(instance, before_all_ivars)
            example.run(instance, reporter)
          ensure
            clear_ivars(instance)
            clear_memoized(instance)
          end
        end.all?
      end

      def self.to_s
        self == RSpec::Core::ExampleGroup ? 'RSpec::Core::ExampleGroup' : name
      end

      def self.all_apply?(filters)
        metadata.all_apply?(filters)
      end

      def self.declaration_line_numbers
        [metadata[:example_group][:line_number]] +
          examples.collect {|e| e.metadata[:line_number]} +
          children.collect {|c| c.declaration_line_numbers}.flatten
      end

      def self.top_level_description
        ancestors.last.description
      end

      def self.set_ivars(instance, ivars)
        ivars.each {|name, value| instance.instance_variable_set(name, value)}
      end

      def self.clear_ivars(instance)
        instance.instance_variables.each { |ivar| instance.send(:remove_instance_variable, ivar) }
      end

      def self.clear_memoized(instance)
        instance.__memoized.clear
      end

      def described_class
        self.class.describes
      end

    private

      def self.extended_modules #:nodoc:
        @extended_modules ||= ancestors.select { |mod| mod.class == Module } - [ Object, Kernel ]
      end

      def self.mixins
        @mixins ||= {
          :include => included_modules,
          :extend => extended_modules
        }
      end

    end
  end
end
