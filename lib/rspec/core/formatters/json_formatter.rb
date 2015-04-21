RSpec::Support.require_rspec_core "formatters/base_formatter"
require 'json'

module RSpec
  module Core
    module Formatters
      # @private
      class JsonFormatter < BaseFormatter
        Formatters.register self, :message, :dump_summary, :dump_profile, :stop, :close,
                            :example_group_started, :example_group_finished,
                            :example_started

        attr_reader :output_hash

        def initialize(output)
          super
          @example_groups= {} #todo rename, maybe example_groups_data ...
          @output_hash = {
            :version => RSpec::Core::Version::STRING
          }
        end

        #todo remove duplication with lib/rspec/core/formatters/profile_formatter.rb line 16
        def example_group_started(notification)
          @example_groups[notification.group.id] = Hash.new(0)
          @example_groups[notification.group.id][:start] = Time.now
          @example_groups[notification.group.id][:description] = notification.group.top_level_description
        end

        def example_group_finished(notification)
          @example_groups[notification.group.id][:total_time] =  Time.now - @example_groups[notification.group.id][:start]
        end

        def example_started(notification)
          group = notification.example.example_group.parent_groups.last.id
          @example_groups[group][:count] += 1
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
              e = example.exception
              if e
                hash[:exception] =  {
                  :class => e.class.name,
                  :message => e.message,
                  :backtrace => e.backtrace,
                }
              end
            end
          end
        end

        def close(_notification)
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
          slowest_groups = profile.calculate_slowest_groups(@example_groups)
          @output_hash[:profile] ||= {}
          @output_hash[:profile][:groups] = slowest_groups.map do |loc, hash|
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
            :run_time => example.execution_result.run_time,
            :pending_message => example.execution_result.pending_message,
          }
        end
      end
    end
  end
end
