require 'rspec/expectations'

Minitest::Test.class_eval do
  include ::RSpec::Matchers

  def expect(*a, &b)
    assert(true) # so each expectation gets counted in minitest's assertion stats
    super
  end
end

module RSpec
  module Expectations
    remove_const :ExpectationNotMetError
    ExpectationNotMetError = ::Minitest::Assertion
  end
end
