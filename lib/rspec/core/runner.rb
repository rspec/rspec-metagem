require 'drb/drb'

module RSpec
  module Core
    class Runner

      def self.at_exit_hook_disabled?
        @no_at_exit_hook ||= false
      end

      def self.disable_at_exit_hook!
        @no_at_exit_hook = true
      end

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.autorun
        return if at_exit_hook_disabled? || installed_at_exit? || running_in_drb?
        @installed_at_exit = true
        at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
      end

      def self.running_in_drb?
        (DRb.current_server rescue false) &&
        !!((DRb.current_server.uri) =~ /druby\:\/\/127.0.0.1\:/)
      end

      def self.run(args, err, out)
        options = ConfigurationOptions.new(args)
        options.parse_options

        if options.options[:drb]
          run_over_drb(options, err, out) || run_in_process(options, err, out)
        else
          run_in_process(options, err, out)
        end
      end

      def self.run_over_drb(options, err, out)
        DRbCommandLine.new(options).run(err, out)
      end

      def self.run_in_process(options, err, out)
        CommandLine.new(options).run(err, out)
      end

    end

  end
end
