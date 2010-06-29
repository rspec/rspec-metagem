module RSpec
  module Core
    class Example

      attr_reader :metadata, :example_block, :options

      def self.delegate_to_metadata(*keys)
        keys.each do |key|
          define_method(key) {@metadata[key]}
        end
      end

      delegate_to_metadata :description, :full_description, :execution_result, :file_path, :pending

      alias_method :inspect, :full_description
      alias_method :to_s, :full_description

      def initialize(example_group_class, desc, options, example_block=nil)
        @example_group_class, @options, @example_block = example_group_class, options, example_block
        @metadata  = @example_group_class.metadata.for_example(desc, options)
        @exception = nil
        @in_block  = false
      end

      def example_group
        @example_group_class
      end

      def behaviour
        RSpec.deprecate("behaviour", "example_group")
        example_group
      end

      def in_block?
        @in_block
      end

      def run(example_group_instance, reporter)
        start
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        begin
          @pending_declared_in_example = catch(:pending_declared_in_example) do
            around_hooks(@example_group_class, @example_group_instance, &wrapped_example).call
            throw :pending_declared_in_example, false
          end
        rescue Exception => e
          @exception ||= e
        ensure
          @example_group_instance.example = nil
          assign_auto_description
        end

        finish(reporter)
      end

    private

      def wrapped_example
        lambda do
          begin
            run_before_each
            @in_block = true
            @example_group_instance.instance_eval(&example_block) unless pending
          rescue Exception => e
            @exception = e
          ensure
            @in_block = false
            run_after_each
          end
        end
      end

      def around_hooks(example_group_class, example_group_instance, &wrapped_example)
        hooks = RSpec.configuration.hooks[:around][:each].dup
        hooks.push example_group_class.ancestors.reverse.map{|a| a.hooks[:around][:each]}
        hooks.flatten.reverse.inject(wrapped_example) do |wrapper, hook|
          def wrapper.run; call; end
          lambda { example_group_instance.instance_exec(wrapper, &hook) }
        end
      end

      def start
        record :started_at => Time.now
      end

      def finish(reporter)
        if @exception
          record_finished 'failed', :exception_encountered => @exception
          reporter.example_failed self
          false
        elsif @pending_declared_in_example
          record_finished 'pending', :pending_message => @pending_declared_in_example
          reporter.example_pending self
          true
        elsif pending
          record_finished 'pending', :pending_message => 'Not Yet Implemented'
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
        @example_group_instance._setup_mocks if @example_group_instance.respond_to?(:_setup_mocks)
        @example_group_class.eval_before_eachs(@example_group_instance)
      end

      def run_after_each
        @example_group_class.eval_after_eachs(@example_group_instance)
        @example_group_instance._verify_mocks if @example_group_instance.respond_to?(:_verify_mocks)
      ensure
        @example_group_instance._teardown_mocks if @example_group_instance.respond_to?(:_teardown_mocks)
      end

      def assign_auto_description
        if description.empty?
          metadata[:description] = RSpec::Matchers.generated_description 
          RSpec::Matchers.clear_generated_description
        end
      end

      def record(results={})
        execution_result.update(results)
      end

    end
  end
end
