module Custom
  class AGeneralFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :message
    attr_reader :call_times

    def message(_notification)
      puts message_builder
    end

    def message_builder
      'Important Message'
    end
  end

  class AMoreSpecificFormatter < AGeneralFormatter
    RSpec::Core::Formatters.register self, :message

    def message_builder
      'Very ' + super
    end
  end
end
