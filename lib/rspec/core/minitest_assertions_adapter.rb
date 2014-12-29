begin
  # Only the minitest 5.x gem includes the minitest.rb and assertions.rb files.
  require 'minitest'
  require 'minitest/assertions'
rescue LoadError
  # We must be using Ruby Core's MiniTest or the Minitest gem 4.x.
  require 'minitest/unit'
  Minitest = MiniTest
end

module RSpec
  module Core
    # @private
    module MinitestAssertionsAdapter
      include ::Minitest::Assertions

      # Minitest 5.x requires this accessor to be available. See
      # https://github.com/seattlerb/minitest/blob/38f0a5fcbd9c37c3f80a3eaad4ba84d3fc9947a0/lib/minitest/assertions.rb#L8
      #
      # It is not required for other extension libraries, and RSpec does not
      # report or make this information available to formatters.
      attr_writer :assertions
      def assertions
        @assertions ||= 0
      end

      RSPEC_SKIP_IMPLEMENTATION = ::RSpec::Core::Pending.instance_method(:skip)
      # Minitest::Assertions has it's own `skip`, we need to make sure
      # RSpec::Core::Pending#skip is used instead.
      def skip(*args)
        RSPEC_SKIP_IMPLEMENTATION.bind(self).call(*args)
      end
    end
  end
end
