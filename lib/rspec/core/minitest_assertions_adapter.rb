module RSpec
  module Core
    # @private
    module MinitestAssertionsAdapter
      include ::Minitest::Assertions

      # Minitest requires this accessor to be available. See
      # https://github.com/seattlerb/minitest/blob/38f0a5fcbd9c37c3f80a3eaad4ba84d3fc9947a0/lib/minitest/assertions.rb#L8
      #
      # It is not required for other extension libraries, and RSpec does not
      # report or make this information available to formatters.
      attr_writer :assertions
      def assertions
        @assertions ||= 0
      end
    end
  end
end
