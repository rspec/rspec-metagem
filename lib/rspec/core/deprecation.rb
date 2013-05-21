module RSpec
  module Core
    module Deprecation
      # @private
      #
      # Used internally to print deprecation warnings
      def deprecate(methodname_or_hash, replacement=nil, version=nil)
        # Temporarily supporting old and new APIs while we transition the other rspec libs to use a hash
        if Hash === methodname_or_hash
          RSpec.configuration.reporter.deprecation methodname_or_hash.merge(:called_from => caller(0)[2])
        else
          RSpec.configuration.reporter.deprecation :method => methodname_or_hash, :replacement => replacement, :version => nil, :called_from => caller(0)[2]
        end
      end

      # @private
      #
      # Used internally to print deprecation warnings
      def warn_deprecation(message)
        RSpec.configuration.reporter.deprecation :message => message
      end
    end
  end

  RSpec.extend(RSpec::Core::Deprecation)
end
