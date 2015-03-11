module RSpec
  module Matchers
    # @api private
    # Facilitates better matcher descriptions and
    # failure messages.
    module Pretty
      # @api private
      # Provides a name for the matcher.
      def name
        defined?(@name) ? @name : underscore(self.class.name.split("::").last)
      end

    private

      # `{ :a => 5, :b => 2 }.inspect` produces:
      #
      #     {:a=>5, :b=>2}
      #
      # ...but it looks much better as:
      #
      #     {:a => 5, :b => 2}
      #
      # This is idempotent and safe to run on a string multiple times.
      def improve_hash_formatting(inspect_string)
        inspect_string.gsub(/(\S)=>(\S)/, '\1 => \2')
      end

      # @private
      # Borrowed from ActiveSupport.
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end
