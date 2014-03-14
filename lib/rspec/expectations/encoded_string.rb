module RSpec
  module Expectations
    # @private
    class EncodedString

      MRI_UNICODE_UNKOWN_CHARACTER = "\xEF\xBF\xBD"

      def initialize(string, encoding = nil)
        @encoding = encoding
        @source_encoding = detect_source_encoding(string)
        @string = matching_encoding(string)
      end
      attr_reader :source_encoding

      delegated_methods = String.instance_methods.map(&:to_s) & %w[eql? lines == encoding]
      delegated_methods.each do |name|
        define_method(name) { |*args, &block| @string.__send__(name, *args, &block) }
      end

      def <<(string)
        @string << matching_encoding(string)
      end

      def split(regex_or_string)
        @string.split(matching_encoding(regex_or_string))
      end

      def to_s
        @string
      end
      alias :to_str :to_s

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
            string.gsub(MRI_UNICODE_UNKOWN_CHARACTER.force_encoding(@encoding), "?")
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
