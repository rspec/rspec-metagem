require "delegate"

module RSpec
  module Expectations
    class EncodedString < SimpleDelegator
      def initialize(string, source=nil)
        super(string)
        @string = string
        @source = source
      end

      def <<(string)
        @string << matching_encoding(string)
      end

      def split(regex_or_string)
        @string.split(matching_encoding(regex_or_string))
      end

      private

      attr_reader :source

      if String.method_defined?(:encoding)
        def matching_encoding(string)
          string.encode(source.encoding)
        end
      else
        def matching_encoding(string)
          string
        end
      end
    end
  end
end
