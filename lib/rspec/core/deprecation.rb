module RSpec
  module Core
    module Deprecation
      # @private
      #
      # Used internally to print deprecation warnings
      def deprecate(deprecated_or_hash, replacement=nil, version=nil)
        # Temporarily supporting old and new APIs while we transition the other rspec libs to use a hash
        if Hash === deprecated_or_hash
          RSpec.configuration.reporter.deprecation deprecated_or_hash.merge(:called_from => caller(0)[2])
        else
          RSpec.configuration.reporter.deprecation :deprecated => deprecated_or_hash, :replacement => replacement, :called_from => caller(0)[2]
        end
      end

      # @private
      #
      # Used internally to print deprecation warnings
      def warn_deprecation(message)
        deprecate(:message => message)
      end
    end
  end

  RSpec.extend(RSpec::Core::Deprecation)
end
