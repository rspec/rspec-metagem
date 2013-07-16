module RSpec
  module Core
    module Deprecation
      # @private
      #
      # Used internally to print deprecation warnings
      def deprecate(deprecated, data = {})
        call_site = caller.find { |line| line !~ %r{/lib/rspec/(core|mocks|expectations|matchers|rails)/} }

        RSpec.configuration.reporter.deprecation(
          {
            :deprecated => deprecated,
            :call_site => call_site
          }.merge(data)
        )
      end

      # @private
      #
      # Used internally to print deprecation warnings
      def warn_deprecation(message)
        RSpec.configuration.reporter.deprecation :message => message
      end
    end
  end

  extend(Core::Deprecation)
end
