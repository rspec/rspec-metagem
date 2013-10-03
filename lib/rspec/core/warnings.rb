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

  # @private
  #
  # Used internally to print warnings
  def self.warning(text, options={})
    warn_with "WARNING: #{text}.", options
  end

  # @private
  #
  # Used internally to print longer warnings
  def self.warn_with(message, options = {})
    call_site = options.fetch(:call_site, CallerFilter.first_non_rspec_line)
    message << " Called from #{call_site}." if call_site
    ::Kernel.warn message
  end

end
