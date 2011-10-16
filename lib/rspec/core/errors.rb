module RSpec
  module Core
    # If Test::Unit is loaed, we'll use its error as baseclass, so that Test::Unit
    # will report unmet RSpec expectations as failures rather than errors.
    begin
      class PendingExampleFixedError < Test::Unit::AssertionFailedError; end
    rescue
      class PendingExampleFixedError < StandardError; end
    end
  end
end


