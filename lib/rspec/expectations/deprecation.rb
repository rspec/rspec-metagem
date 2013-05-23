module RSpec
  module Expectations
    module Deprecation
      # @private
      #
      # Used internally to print deprecation warnings
      def deprecate(deprecated, options={})
        message = "DEPRECATION: #{deprecated} is deprecated."
        message << " Use #{options[:replacement]} instead." if options[:replacement]
        message << " Called from #{caller(0)[2]}."
        warn message
      end
    end
  end

  extend(Expectations::Deprecation) unless respond_to?(:deprecate)
end
