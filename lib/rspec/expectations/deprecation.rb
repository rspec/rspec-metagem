require 'rspec/caller_filter'

module RSpec
  module Expectations
    module Deprecation
      # @private
      #
      # Used internally to print deprecation warnings
      def deprecate(deprecated, options={})
        message = "DEPRECATION: #{deprecated} is deprecated."
        message << " Use #{options[:replacement]} instead." if options[:replacement]
        message << " Called from #{CallerFilter.first_non_rspec_line}."
        warn message
      end
    end
  end

  extend(Expectations::Deprecation) unless respond_to?(:deprecate)
end
