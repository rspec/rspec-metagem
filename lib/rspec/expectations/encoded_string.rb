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

      if String.method_defined?(:encoding)
        def matching_encoding(string)
          string.encode(@encoding)
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          normalize_missing(string.encode(@encoding, :invalid => :replace, :undef => :replace))
        rescue Encoding::ConverterNotFoundError
          normalize_missing(string.force_encoding(@encoding).encode(:invalid => :replace))
        end

        def normalize_missing(string)
          if @encoding.to_s == "UTF-8"
            string.gsub("\xEF\xBF\xBD".force_encoding(@encoding), "?")
          else
            string
          end
        end
      else
        def matching_encoding(string)
          string
        end
      end
    end
  end
end
