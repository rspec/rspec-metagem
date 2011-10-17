module RSpec
  module Matchers
    class BaseMatcher
      include RSpec::Matchers::Pretty

      attr_reader :actual, :expected

      def initialize(expected)
        @expected = expected
      end

      def failure_message_for_should
        "expected #{actual.inspect} to #{name_to_sentence}#{expected_to_sentence}"
      end

      def failure_message_for_should_not
        "expected #{actual.inspect} not to #{name_to_sentence}#{expected_to_sentence}"
      end


      # from matcher.rb
      def name_to_sentence
        split_words(name)
      end

      def expected_to_sentence
        to_sentence(@expected)
      end

      def name
        defined?(@name) ? @name : self.class.name.split("::").last.downcase
      end

    end
  end
end
