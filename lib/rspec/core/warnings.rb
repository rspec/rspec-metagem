module RSpec

  # @private
  #
  # Used internally to print deprecation warnings
  def self.deprecate(deprecated, data = {})
    RSpec.configuration.reporter.deprecation(
      {
        :deprecated => deprecated,
        :call_site => CallerFilter.first_non_rspec_line
      }.merge(data)
    )
  end

  # @private
  #
  # Used internally to print deprecation warnings
  def self.warn_deprecation(message)
    RSpec.configuration.reporter.deprecation :message => message
  end

end
