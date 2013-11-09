require "delegate"

module RSpec
  module Expectations
    class EncodedString < SimpleDelegator
      def initialize(string, encoding=nil)
        @encoding = encoding
        @string = matching_encoding(string)
        super(@string)
      end

      def <<(string)
        @string << matching_encoding(string)
      end

      def split(regex_or_string)
        @string.split(matching_encoding(regex_or_string))
      end

      private

      attr_reader :encoding

      if String.method_defined?(:encoding)
        def matching_encoding(string)
          string.encode(encoding)
        rescue Encoding::UndefinedConversionError
          string.encode(encoding, :undef => :replace)
        end
      else
        def matching_encoding(string)
          string
        end
      end
    end
  end
end
