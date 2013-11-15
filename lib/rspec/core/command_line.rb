module RSpec
  module Core
    # The 'rspec' command line
    class CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        @options       = options
        @configuration = configuration
        @world         = world
      end

      # Configures and runs a suite
      #
      # @param err [IO]
      # @param out [IO]
      def run(err, out)
        setup(err, out)
        run_specs
      end

      def setup(err, out)
        @configuration.error_stream = err
        @configuration.output_stream = out if @configuration.output_stream == $stdout
        @options.configure(@configuration)
        @configuration.load_spec_files
        @world.announce_filters
      end

      def run_specs
        @configuration.reporter.report(@world.example_count) do |reporter|
          begin
            hook_context = SuiteHookContext.new
            @configuration.hooks.run(:before, :suite, hook_context)
            @world.ordered_example_groups.map {|g| g.run(reporter) }.all? ? 0 : @configuration.failure_exit_code
          ensure
            @configuration.hooks.run(:after, :suite, hook_context)
          end
        end
      end
    end
  end
end
