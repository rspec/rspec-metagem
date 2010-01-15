module Rspec
  module Core
    class Example

      attr_reader :behaviour, :metadata, :example_block

      def initialize(behaviour, desc, options, example_block=nil)
        @behaviour, @options, @example_block = behaviour, options, example_block
        @metadata = @behaviour.metadata.dup
        @metadata[:description] = desc.to_s
        @metadata[:execution_result] = {}
        @metadata[:caller] = options.delete(:caller)
        if @metadata[:caller]
          @metadata[:file_path] = @metadata[:caller].split(":")[0].strip 
          @metadata[:line_number] = @metadata[:caller].split(":")[1].to_i
        end
        @metadata.update(options)
      end

      def description
        metadata[:description]
      end
      
      def record_results(results={})
        @metadata[:execution_result].update(results)
      end

      def execution_result
        @metadata[:execution_result]
      end

      def file_path
        @metadata[:file_path] || behaviour.file_path
      end

      def run_started
        record_results :started_at => Time.now
      end

      def run_passed
        run_finished 'passed'
      end

      def run_pending(message='Not yet implemented')
        run_finished 'pending', :pending_message => message
      end

      def run_failed(exception)
        run_finished 'failed', :exception_encountered => exception
      end

      def run_finished(status, results={})
        record_results results.update(:status => status)
        finish_time = Time.now
        record_results :finished_at => finish_time, :run_time => (finish_time - execution_result[:started_at])
        Rspec::Core.configuration.formatter.example_finished(self)
      end

      def run_before_each
        @example_group_instance._setup_mocks if @example_group_instance.respond_to?(:_setup_mocks)
        @behaviour.eval_before_eachs(@example_group_instance)
      end

      def run_after_each
        @behaviour.eval_after_eachs(@example_group_instance)
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

      class AroundProxy
        def initialize(example_group_instance, &example_block)
          @example_group_instance, @example_block = example_group_instance, example_block
        end

        def run
          @example_group_instance.instance_eval(&@example_block)
        end
      end

      def run(example_group_instance)
        @example_group_instance = example_group_instance
        # @example_group_instance = example_group_instance.reset
        @example_group_instance.running_example = self

        run_started

        all_systems_nominal = true
        exception_encountered = nil

        begin
          run_before_each
          if @behaviour.around_eachs.empty?
            @example_group_instance.instance_eval(&example_block) if example_block
          else
            @behaviour.around_eachs.first.call(AroundProxy.new(self, &example_block))
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
          run_failed(exception_encountered) 
        else
          example_block ? run_passed : run_pending
        end

        all_systems_nominal
      end

      def inspect
        "#{@metadata[:behaviour][:name]} - #{@metadata[:description]}"
      end

      def to_s
        inspect
      end

    end

  end
end
