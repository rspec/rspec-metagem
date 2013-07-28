require 'rspec/core/formatters/base_formatter'
require 'json'

module RSpec
  module Core
    module Formatters

      class JsonFormatter < BaseFormatter

        attr_reader :output_hash

        def initialize(output)
          super
          @output_hash = {}
        end

        def notifications
          (super + [:message, :dump_summary, :stop, :close, :dump_profile]).uniq
        end

        def message(message)
          (@output_hash[:messages] ||= []) << message
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          super(duration, example_count, failure_count, pending_count)
          @output_hash[:summary] = {
            :duration => duration,
            :example_count => example_count,
            :failure_count => failure_count,
            :pending_count => pending_count
          }
          @output_hash[:summary_line] = summary_line(example_count, failure_count, pending_count)

          dump_profile unless mute_profile_output?(failure_count)
        end

        def stop
          @output_hash[:examples] = examples.map do |example|
            format_example(example).tap do |hash|
              if e=example.exception
                hash[:exception] =  {
                  :class => e.class.name,
                  :message => e.message,
                  :backtrace => e.backtrace,
                }
              end
            end
          end
        end

        def close
          output.write @output_hash.to_json
          output.close if IO === output && output != $stdout
        end

        def dump_profile
          @output_hash[:profile] = {}
          dump_profile_slowest_examples
          dump_profile_slowest_example_groups
        end

        # @api private
        def dump_profile_slowest_examples
          @output_hash[:profile] = {}
          sorted_examples = slowest_examples
          @output_hash[:profile][:examples] = sorted_examples[:examples].map do |example|
            format_example(example).tap do |hash|
              hash[:run_time] = example.execution_result[:run_time]
            end
          end
          @output_hash[:profile][:slowest] = sorted_examples[:slows]
          @output_hash[:profile][:total] = sorted_examples[:total]
        end

        # @api private
        def dump_profile_slowest_example_groups
          @output_hash[:profile] ||= {}
          @output_hash[:profile][:groups] = slowest_groups.map do |loc, hash|
            hash.update(:location => loc)
          end
        end

      private

        def summary_line(example_count, failure_count, pending_count)
          summary = pluralize(example_count, "example")
          summary << ", " << pluralize(failure_count, "failure")
          summary << ", #{pending_count} pending" if pending_count > 0
          summary
        end


        def format_example(example)
          {
            :description => example.description,
            :full_description => example.full_description,
            :status => example.execution_result[:status],
            :file_path => example.metadata[:file_path],
            :line_number  => example.metadata[:line_number],
            :run_time => example.execution_result[:run_time]
          }
        end
      end
    end
  end
end
