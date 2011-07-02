module Kernel
  # Passes if +matcher+ returns true.  Available on every +Object+.
  # @example
  #   actual.should eq(expected)
  #   actual.should be > 4
  # @param [Matcher]
  #   matcher
  # @param [String] message optional message to display when the expectation fails
  # @return [Boolean] true if the expectation succeeds (else raises)
  # @see RSpec::Matchers
  def should(matcher=nil, message=nil, &block)
    RSpec::Expectations::PositiveExpectationHandler.handle_matcher(self, matcher, message, &block)
  end

  # Passes if +matcher+ returns false.  Available on every +Object+.
  # @example
  #   actual.should_not eq(expected)
  # @param [Matcher]
  #   matcher
  # @param [String] message optional message to display when the expectation fails
  # @return [Boolean] false if the negative expectation succeeds (else raises)
  # @see RSpec::Matchers
  def should_not(matcher=nil, message=nil, &block)
    RSpec::Expectations::NegativeExpectationHandler.handle_matcher(self, matcher, message, &block)
  end
end
