module RSpec
  module Core
    # Wrapper for an instance of a subclass of [ExampleGroup](ExampleGroup). An
    # instance of `Example` is returned by the
    # [example](ExampleGroup#example-instance_method) method available in
    # examples, [before](Hooks#before-instance_method) and
    # [after](Hooks#after-instance_method) hooks, and yielded to
    # [around](Hooks#around-instance_method) hooks.
    # @see ExampleGroup
    class Example
      # @private
      #
      # Used to define methods that delegate to this example's metadata
      def self.delegate_to_metadata(*keys)
        keys.each do |key|
          define_method(key) {@metadata[key]}
        end
      end

      delegate_to_metadata :description, :full_description, :execution_result, :file_path, :pending, :location

      # @attr_reader
      #
      # Returns the first exception raised in the context of running this
      # example (nil if no exception is raised)
      attr_reader :exception

      # @attr_reader
      #
      # Returns the metadata object associated with this example.
      attr_reader :metadata

      # @attr_reader
      # @private
      #
      # Returns the example_group_instance that provides the context for
      # running this example.
      attr_reader :example_group_instance

      # Creates a new instance of Example.
      # @param example_group_class the subclass of ExampleGroup in which this Example is declared
      # @param description the String passed to the `it` method (or alias)
      # @param metadata additional args passed to `it` to be used as metadata
      # @param example_block the block of code that represents the example
      def initialize(example_group_class, description, metadata, example_block=nil)
        @example_group_class, @options, @example_block = example_group_class, metadata, example_block
        @metadata  = @example_group_class.metadata.for_example(description, metadata)
        @exception = nil
        @pending_declared_in_example = false
      end

      # @deprecated access options via metadata instead
      def options
        @options
      end

      # Returns the example group class that provides the context for running
      # this example.
      def example_group
        @example_group_class
      end

      alias_method :pending?, :pending

      # @api private
      # @param example_group_instance the instance of an ExampleGroup subclass
      # instance_evals the block submitted to the constructor in the
      # context of the instance of ExampleGroup
      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        start(reporter)

        begin
          unless pending
            with_around_hooks do
              begin
                run_before_each
                @example_group_instance.instance_eval(&@example_block)
              rescue Pending::PendingDeclaredInExample => e
                @pending_declared_in_example = e.message
              rescue Exception => e
                set_exception(e)
              ensure
                run_after_each
              end
            end
          end
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.instance_variables.each do |ivar|
            @example_group_instance.instance_variable_set(ivar, nil)
          end
          @example_group_instance = nil

          begin
            assign_auto_description
          rescue Exception => e
            set_exception(e)
          end
        end

        finish(reporter)
      end

      # @private
      #
      # Wraps the example block in a Proc so it can invoked using `run` or
      # `call` in [around](../Hooks#around-instance_method) hooks.
      def self.procsy(metadata, &proc)
        Proc.new(&proc).extend(Procsy).with(metadata)
      end

      # @private
      module Procsy
        attr_reader :metadata

        # @private
        # @param [Proc]
        # Adds a `run` method to the extended Proc, allowing it to be invoked
        # in an [around](../Hooks#around-instance_method) hook using either
        # `run` or `call`.
        def self.extended(object)
          def object.run; call; end
        end

        # @private
        def with(metadata)
          @metadata = metadata
          self
        end
      end

      # @private
      def any_apply?(filters)
        metadata.any_apply?(filters)
      end

      # @private
      def all_apply?(filters)
        @metadata.all_apply?(filters) || @example_group_class.all_apply?(filters)
      end

      # @private
      def around_hooks
        @around_hooks ||= example_group.around_hooks_for(self)
      end

      # @private
      #
      # Used internally to set an exception in an after hook, which
      # captures the exception but doesn't raise it.
      def set_exception(exception)
        @exception ||= exception
      end

      # @private
      #
      # Used internally to set an exception and fail without actually executing
      # the example when an exception is raised in before(:all).
      def fail_with_exception(reporter, exception)
        start(reporter)
        set_exception(exception)
        finish(reporter)
      end

    private

      def with_around_hooks(&block)
        if around_hooks.empty?
          yield
        else
          @example_group_class.run_around_each_hooks(self, Example.procsy(metadata, &block)).call
        end
      end

      def start(reporter)
        reporter.example_started(self)
        record :started_at => Time.now
      end

      # @private
      module NotPendingExampleFixed
        def pending_fixed?; false; end
      end

      def finish(reporter)
        if @exception
          @exception.extend(NotPendingExampleFixed) unless @exception.respond_to?(:pending_fixed?)
          record_finished 'failed', :exception => @exception
          reporter.example_failed self
          false
        elsif @pending_declared_in_example
          record_finished 'pending', :pending_message => @pending_declared_in_example
          reporter.example_pending self
          true
        elsif pending
          record_finished 'pending', :pending_message => String === pending ? pending : Pending::NO_REASON_GIVEN
          reporter.example_pending self
          true
        else
          record_finished 'passed'
          reporter.example_passed self
          true
        end
      end

      def record_finished(status, results={})
        finished_at = Time.now
        record results.merge(:status => status, :finished_at => finished_at, :run_time => (finished_at - execution_result[:started_at]))
      end

      def run_before_each
        @example_group_instance.setup_mocks_for_rspec if @example_group_instance.respond_to?(:setup_mocks_for_rspec)
        @example_group_class.run_before_each_hooks(self)
      end

      def run_after_each
        @example_group_class.run_after_each_hooks(self)
        @example_group_instance.verify_mocks_for_rspec if @example_group_instance.respond_to?(:verify_mocks_for_rspec)
      ensure
        @example_group_instance.teardown_mocks_for_rspec if @example_group_instance.respond_to?(:teardown_mocks_for_rspec)
      end

      def assign_auto_description
        if description.empty? and !pending?
          if RSpec.configuration.expecting_with_rspec?
            metadata[:description] = RSpec::Matchers.generated_description
            RSpec::Matchers.clear_generated_description
          else
            raise NotImplementedError.new(
              "Generated descriptions are only supported when you use rspec-expectations.  " +
              "You must give every example an explicit description."
            )
          end
        end
      end

      def record(results={})
        execution_result.update(results)
      end

    end
  end
end
