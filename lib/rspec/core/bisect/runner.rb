RSpec::Support.require_rspec_core "shell_escape"

module RSpec
  module Core
    module Bisect
      # Provides an API to run the suite for a set of locations, using
      # the given bisect server to capture the results.
      # @private
      class Runner
        include RSpec::Core::ShellEscape

        attr_reader :original_cli_args

        def initialize(server, original_cli_args)
          @server            = server
          @original_cli_args = original_cli_args - ["--bisect"]
        end

        def run(locations)
          run_locations(locations, original_results.failed_example_ids)
        end

        def command_for(locations)
          parts = []

          parts << RUBY << load_path
          parts << escape(RSpec::Core.path_to_executable)

          parts << "--format"   << "bisect"
          parts << "--drb-port" << @server.drb_port
          parts.concat reusable_cli_options
          parts.concat locations.map { |l| escape(l) }

          parts.join(" ")
        end

        def repro_command_from(locations)
          parts = []

          parts << "rspec"
          parts.concat organize_locations(locations)
          parts.concat original_cli_args_without_locations

          parts.join(" ")
        end

        def original_results
          @original_results ||= run_locations(original_locations)
        end

      private

        def run_locations(locations, *capture_args)
          @server.capture_run_results(*capture_args) do
            system command_for(locations)
          end
        end

        def reusable_cli_options
          @reusable_cli_options ||= begin
            opts = original_cli_args_without_locations

            if (port = parsed_original_cli_options[:drb_port])
              opts -= %W[ --drb-port #{port} ]
            end

            parsed_original_cli_options.fetch(:formatters) { [] }.each do |(name, out)|
              opts -= %W[ --format #{name} ]
              opts -= %W[ --out #{out} ]
              opts -= %W[ -f #{name} ]
              opts -= %W[ -o #{out} ]
            end

            opts
          end
        end

        def organize_locations(locations)
          grouped = locations.inject(Hash.new { |h, k| h[k] = [] }) do |hash, location|
            file, id = location.split(Configuration::ON_SQUARE_BRACKETS)
            hash[file] << id
            hash
          end

          grouped.sort_by(&:first).map do |file, ids|
            ids = ids.sort_by { |id| id.split(':').map(&:to_i) }
            id  = Metadata.id_from(:rerun_file_path => file, :scoped_id => ids.join(','))
            conditionally_quote(id)
          end
        end

        def original_cli_args_without_locations
          @original_cli_args_without_locations ||= begin
            files_or_dirs = parsed_original_cli_options.fetch(:files_or_directories_to_run)
            @original_cli_args - files_or_dirs
          end
        end

        def parsed_original_cli_options
          @parsed_original_cli_options ||= Parser.parse(@original_cli_args)
        end

        def original_locations
          parsed_original_cli_options.fetch(:files_or_directories_to_run)
        end

        def load_path
          @load_path ||= "-I#{$LOAD_PATH.map { |p| escape(p) }.join(':')}"
        end

        # Path to the currently running Ruby executable, borrowed from Rake:
        # https://github.com/ruby/rake/blob/v10.4.2/lib/rake/file_utils.rb#L8-L12
        # Note that we skip `ENV['RUBY']` because we don't have to deal with running
        # RSpec from within a MRI source repository:
        # https://github.com/ruby/rake/commit/968682759b3b65e42748cd2befb2ff3e982272d9
        RUBY = File.join(
          RbConfig::CONFIG['bindir'],
          RbConfig::CONFIG['ruby_install_name'] + RbConfig::CONFIG['EXEEXT']).
          sub(/.*\s.*/m, '"\&"')
      end
    end
  end
end
