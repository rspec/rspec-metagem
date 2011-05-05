module RSpec
  module Matchers
    # :call-seq:
    #   should cover(expected)
    #   should_not cover(expected)
    #
    # Passes if actual covers expected. This works for
    # Ranges. You can also pass in multiple args
    # and it will only pass if all args are found in Range.
    #
    # == Examples
    #   (1..10).should cover(5)
    #   (1..10).should cover(4, 6)
    #   (1..10).should cover(4, 6, 11) # will fail
    #   (1..10).should_not cover(11)
    #   (1..10).should_not cover(5)    # will fail
    #
    # == Warning: Ruby >= 1.9 only
    def cover(*expected_values)
      Matcher.new :cover, *expected_values do |*_expected_values|
        match_for_should do |actual|
          _expected_values.all? &cover_value
        end

        match_for_should_not do |actual|
          _expected_values.none? &cover_value
        end

        def cover_value
          lambda {|value| actual.cover?(value)}
        end
      end
    end
  end
end
