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
