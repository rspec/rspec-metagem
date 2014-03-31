RSpec::Matchers.define :include_method do |expected|
  match do |actual|
    actual.map { |m| m.to_s }.include?(expected.to_s)
  end
end

module RSpec
  module Matchers
    def fail
      raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(RSpec::Expectations::ExpectationNotMetError, message)
    end

    def fail_matching(message)
      if String === message
        regexp = /#{Regexp.escape(message)}/
      else
        regexp = message
      end
      raise_error(RSpec::Expectations::ExpectationNotMetError, regexp)
    end
  end
end
