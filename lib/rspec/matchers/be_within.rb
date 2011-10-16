module RSpec
  module Matchers
    # Passes if actual == expected +/- delta
    #
    # == Examples
    #
    #   result.should be_within(0.5).of(3.0)
    #   result.should_not be_within(0.5).of(3.0)
    def be_within(delta)
      Matcher.new :be_within, delta do |_delta_|
        chain :of do |_expected_|
          @_expected = _expected_
        end

        match do |actual|
          unless defined?(@_expected)
            raise ArgumentError.new("You must set an expected value using #of: be_within(#{_delta_}).of(expected_value)")
          end
          (actual - @_expected).abs < _delta_
        end

        failure_message_for_should do |actual|
          "expected #{actual} to #{description}"
        end

        failure_message_for_should_not do |actual|
          "expected #{actual} not to #{description}"
        end

        description do
          "be within #{_delta_} of #{@_expected}"
        end
      end
    end
  end
end

