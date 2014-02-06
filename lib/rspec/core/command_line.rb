module RSpec
  module Core
    class CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        if Array === options
          options = ConfigurationOptions.new(options)
        end
        @options       = options
        @configuration = configuration
        @world         = world
      end

      # Configures and runs a suite
      #
      # @param [IO] err
      # @param [IO] out
      def run(err, out)
        @configuration.error_stream = err
        @configuration.output_stream = out if @configuration.output_stream == $stdout
        @options.configure(@configuration)
        @configuration.load_spec_files
        @world.announce_filters

        @configuration.reporter.report(@world.example_count) do |reporter|
          begin
            @configuration.hooks.run(:before, :suite)
            @world.ordered_example_groups.map {|g| g.run(reporter) }.all? ? 0 : @configuration.failure_exit_code
          ensure
            @configuration.hooks.run(:after, :suite)
          end
        end
      end
    end
  end
end
