module FormatterSupport

  def send_notification notification, *args
    reporter.notify notification, *args
  end

  def reporter
    @reporter ||= setup_reporter
  end

  def setup_reporter(*streams)
    config.add_formatter described_class, *streams
    @formatter = config.formatters.first
    @reporter = config.reporter
  end

  def output
    @output ||= StringIO.new
  end

  def config
    @configuration ||=
      begin
        config = RSpec::Core::Configuration.new
        config.output_stream = output
        config
      end
  end

  def configure
    yield config
  end

  def formatter
    @formatter ||=
      begin
        setup_reporter
        @formatter
      end
  end

  def example
    instance_double("RSpec::Core::Example",
                    :description      => "Example",
                    :full_description => "Example",
                    :execution_result => { :exception => Exception.new },
                    :metadata         => {}
                   )
  end

end
