RSpec::Support.require_rspec_core "formatters/base_formatter"
require 'json'

module RSpec
  module Core
    module Formatters
      # @private
      class JsonFormatter < BaseFormatter
        Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :close

        attr_reader :output_hash

        def initialize(output)
          super
          @output_hash = {}
        end

        def message(notification)
          (@output_hash[:messages] ||= []) << notification.message
        end

        def dump_summary(summary)
          @output_hash[:summary] = {
            :duration => summary.duration,
            :example_count => summary.example_count,
            :failure_count => summary.failure_count,
            :pending_count => summary.pending_count
          }
          @output_hash[:summary_line] = summary.totals_line
        end

        def stop(notification)
          @output_hash[:examples] = notification.examples.map do |example|
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

        def close(notification)
          output.write @output_hash.to_json
          output.close if IO === output && output != $stdout
        end

        def dump_profile(profile)
          @output_hash[:profile] = {}
          dump_profile_slowest_examples(profile)
          dump_profile_slowest_example_groups(profile)
        end

        # @api private
        def dump_profile_slowest_examples(profile)
          @output_hash[:profile] = {}
          sorted_examples = profile.slowest_examples
          @output_hash[:profile][:examples] = sorted_examples.map do |example|
            format_example(example).tap do |hash|
              hash[:run_time] = example.execution_result.run_time
            end
          end
          @output_hash[:profile][:slowest] = profile.slow_duration
          @output_hash[:profile][:total] = profile.duration
        end

        # @api private
        def dump_profile_slowest_example_groups(profile)
          @output_hash[:profile] ||= {}
          @output_hash[:profile][:groups] = profile.slowest_groups.map do |loc, hash|
            hash.update(:location => loc)
          end
        end

      private

        def format_example(example)
          {
            :description => example.description,
            :full_description => example.full_description,
            :status => example.execution_result.status.to_s,
            :file_path => example.metadata[:file_path],
            :line_number  => example.metadata[:line_number],
            :run_time => example.execution_result.run_time
          }
        end
      end
    end
  end
end
