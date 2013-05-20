module RSpec
  class << self
    # @private
    #
    # Used internally to print deprecation warnings
    def deprecate(method, alternate_method=nil, version=nil)
      RSpec.configuration.reporter.deprecation :method => method, :alternate_method => alternate_method, :version => nil, :called_from => caller(0)[2]
    end

    # @private
    #
    # Used internally to print deprecation warnings
    def warn_deprecation(message)
      RSpec.configuration.reporter.deprecation :message => message
    end
  end
end
