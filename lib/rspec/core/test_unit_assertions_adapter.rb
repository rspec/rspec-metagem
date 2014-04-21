require 'test/unit/assertions'

module RSpec
  module Core
    # @private
    module TestUnitAssertionsAdapter
      include ::Test::Unit::Assertions

      # If using test/unit from Ruby core with Ruby greater than 1.8.7, it
      # includes the MiniTest::Assertions by default.
      #
      # If the test/unit gem is being loaded, it will not include the Minitest
      # assertions. Thus instead of checking on the RUBY_VERSION we need to
      # check ancestors.
      begin
        if ancestors.include?(::Minitest::Assertions)
          require 'rspec/core/minitest_assertions_adapter'
          include ::RSpec::Core::MinitestAssertionsAdapter
        end
      rescue NameError => _ignored
        # No-op. Minitest::Assertions isn't loaded
      end
    end
  end
end

