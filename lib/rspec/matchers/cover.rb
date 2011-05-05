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
    #   (1..10).should_not cover(5) # will fail
    def cover(*expected)
      Matcher.new :cover, *expected do |*_expected|

        match_for_should do |actual|
          perform_match(:all?, actual, _expected)
        end

        match_for_should_not do |actual|
          perform_match(:none?, actual, _expected)
        end

        def perform_match(predicate, actual, _expected)
          _expected.send(predicate) do |expected|
              actual.cover?(expected)
          end
        end
      end
    end
  end
end
