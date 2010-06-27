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
        @metadata = @example_group_class.metadata.for_example(desc, options)
      end

      def example_group
        @example_group_class
      end

      def in_block?
        @in_block
      end

      alias_method :behaviour, :example_group

      def run(example_group_instance, reporter)
        start
        @in_block = false
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        exception = nil

        the_example = lambda do
          begin
            run_before_each
            @in_block = true
            @example_group_instance.instance_eval(&example_block) unless pending
          rescue Exception => e
            exception = e
          ensure
            @in_block = false
            run_after_each
          end
        end

        begin
          pending_declared_in_example = catch(:pending_declared_in_example) do
            around_hooks(@example_group_class, @example_group_instance, the_example).call
            throw :pending_declared_in_example, false
          end
        rescue Exception => e
          exception = e
        ensure
          @example_group_instance.example = nil
          assign_auto_description
        end

        if exception
          run_failed(reporter, exception) 
          false
        elsif pending_declared_in_example
          run_pending(reporter, pending_declared_in_example)
          true
        elsif pending
          run_pending(reporter, 'Not Yet Implemented')
          true
        else
          run_passed(reporter) 
          true
        end
      end

    private

      def around_hooks(example_group_class, example_group_instance, the_example)
        hooks = RSpec.configuration.hooks[:around][:each]
        hooks.push example_group_class.ancestors.reverse.map{|a| a.hooks[:around][:each]}
        hooks.flatten.reverse.inject(the_example) do |accum, hook|
          def accum.run; call; end
          lambda { example_group_instance.instance_exec(accum, &hook) }
        end
      end

      def start
        record_results :started_at => Time.now
      end

      def run_passed(reporter=nil)
        run_finished reporter, 'passed'
      end

      def run_pending(reporter, message)
        run_finished reporter, 'pending', :pending_message => message
      end

      def run_failed(reporter, exception)
        run_finished reporter, 'failed', :exception_encountered => exception
      end

      def run_finished(reporter, status, results={})
        record_results results.update(:status => status)
        finish_time = Time.now
        record_results :finished_at => finish_time, :run_time => (finish_time - execution_result[:started_at])
        reporter.example_finished(self)
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

      def record_results(results={})
        execution_result.update(results)
      end

    end
  end
end
