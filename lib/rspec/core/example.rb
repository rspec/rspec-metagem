module Rspec
  module Core
    class Example

      attr_reader :metadata, :example_block

      def example_group
        @example_group_class
      end

      alias_method :behaviour, :example_group

      def initialize(example_group_class, desc, options, example_block=nil)
        @example_group_class, @options, @example_block = example_group_class, options, example_block
        @metadata = @example_group_class.metadata.for_example(desc, options)
      end

      def description
        @metadata[:description]
      end

      def record_results(results={})
        @metadata[:execution_result].update(results)
      end

      def execution_result
        @metadata[:execution_result]
      end

      def file_path
        @metadata[:file_path] || example_group.file_path
      end

      def inspect
        @metadata[:full_description]
      end

      def to_s
        inspect
      end

      def run_started
        record_results :started_at => Time.now
      end

      def run_passed(reporter=nil)
        run_finished reporter, 'passed'
      end

      def run_pending(reporter=nil)
        message = metadata[:execution_result][:pending_message] || 'Not Yet Implemented'
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
          metadata[:description] = Rspec::Matchers.generated_description 
          Rspec::Matchers.clear_generated_description
        end
      end

      def runnable?
        !metadata[:pending]
      end

      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @example_group_instance.running_example = self

        run_started

        all_systems_nominal = true
        exception_encountered = nil

        begin
          run_before_each
          if @example_group_class.around_eachs.empty?
            @example_group_instance.instance_eval(&example_block) if runnable?
          else
            @example_group_class.around_eachs.first.call(AroundProxy.new(self, &example_block))
          end
        rescue Exception => e
          exception_encountered = e
          all_systems_nominal = false
        end

        assign_auto_description

        begin
          run_after_each
        rescue Exception => e
          exception_encountered ||= e
          all_systems_nominal = false
        ensure
          @example_group_instance.running_example = nil
        end

        if exception_encountered
          run_failed(reporter, exception_encountered) 
        else
          runnable? ? run_passed(reporter) : run_pending(reporter)
        end

        all_systems_nominal
      end


    end

  end
end
