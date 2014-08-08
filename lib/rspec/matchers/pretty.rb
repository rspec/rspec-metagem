module RSpec
  module Matchers
    # @api private
    # Contains logic to facilitate converting ruby symbols and
    # objects to english phrases.
    module Pretty
      # @api private
      # Converts a symbol into an english expression.
      def split_words(sym)
        sym.to_s.gsub(/_/, ' ')
      end
      module_function :split_words

      # @api private
      # Converts a collection of objects into an english expression.
      def to_sentence(words)
        return " #{words.inspect}" if !words || Struct === words
        words = Array(words).map { |w| to_word(w) }
        case words.length
        when 0
          ""
        when 1
          " #{words[0]}"
        when 2
          " #{words[0]} and #{words[1]}"
        else
          " #{words[0...-1].join(', ')}, and #{words[-1]}"
        end
      end

      # @api private
      # Converts the given item to string suitable for use in a list expression.
      def to_word(item)
        is_matcher_with_description?(item) ? item.description : item.inspect
      end

      # @private
      # Provides an English expression for the matcher name.
      def name_to_sentence
        split_words(name)
      end

      # @api private
      # Provides a name for the matcher.
      def name
        defined?(@name) ? @name : underscore(self.class.name.split("::").last)
      end

      # @private
      # Borrowed from ActiveSupport
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

    private

      def is_matcher_with_description?(object)
        RSpec::Matchers.is_a_matcher?(object) && object.respond_to?(:description)
      end

      # `{ :a => 5, :b => 2 }.inspect` produces:
      #    {:a=>5, :b=>2}
      # ...but it looks much better as:
      #    {:a => 5, :b => 2}
      #
      # This is idempotent and safe to run on a string multiple times.
      def improve_hash_formatting(inspect_string)
        inspect_string.gsub(/(\S)=>(\S)/, '\1 => \2')
      end
    end
  end
end
