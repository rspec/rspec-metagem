module Rspec
  module Core
    module KernelExtensions

      unless respond_to?(:debugger)
        # Start a debugging session if ruby-debug is loaded with the -u/--debugger option
        def debugger(steps=1)
          # If not then just comment and proceed
          $stderr.puts "debugger statement ignored, use -d or --debug option on rspec to enable debugging"
        end
      end

      def describe(*args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update :caller => caller(1)
        Rspec::Core::ExampleGroup.describe(*args, &example_group_block)
      end

      alias :context :describe

    end
  end
end

include Rspec::Core::KernelExtensions
