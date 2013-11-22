require "delegate"

module RSpec
  module Expectations
    class EncodedString < SimpleDelegator

      def initialize(string, encoding = nil)
        @encoding = encoding
        @source_encoding = detect_source_encoding(string)
        @string = matching_encoding(string)
        super(@string)
      end
      attr_reader :source_encoding

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

        def detect_source_encoding(string)
          string.encoding
        end
      else
        def matching_encoding(string)
          string
        end

        def detect_source_encoding(string)
          'US-ASCII'
        end
      end
    end
  end
end
