module RSpec
  module Core
    # A sandbox isolates the enclosed code into an environment that looks 'new'
    # meaning globally accessed objects are reset for the duration of the
    # sandbox.
    module Sandbox
      # Execute a provided block with RSpec global objects (configuration,
      # world) reset.  This is used to test RSpec with RSpec.
      #
      # When calling this the configuration is passed into the provided block.
      # Use this to set custom configs for your sandboxed examples.
      #
      # ```
      # Sandbox.sandboxed do |config|
      #   config.before(:context) { RSpec.current_example = nil }
      # end
      # ```
      def self.sandboxed
        orig_config = RSpec.configuration
        orig_world  = RSpec.world
        orig_example = RSpec.current_example

        new_config = RSpec::Core::Configuration.new
        new_world  = RSpec::Core::World.new(new_config)

        RSpec.configuration = new_config
        RSpec.world = new_world

        yield new_config
      ensure
        RSpec.configuration = orig_config
        RSpec.world = orig_world
        RSpec.current_example = orig_example
      end
    end
  end
end
