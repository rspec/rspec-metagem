module RSpec::Core

  CountNotification       = Struct.new(:count)
  ExampleNotification     = Struct.new(:example)
  GroupNotification       = Struct.new(:group)
  MessageNotification     = Struct.new(:message)
  SeedNotification        = Struct.new(:seed,:used) do
    def seed_used?
      !!used
    end
  end
  SummaryNotification     = Struct.new(:duration, :examples, :failures, :pending)

  class DeprecationNotification
    def initialize(data)
      @call_site   = data[:call_site]
      @deprecated  = data[:deprecated]
      @message     = data[:message]
      @replacement = data[:replacement]
      @data = data
    end
    attr_reader :message, :replacement, :deprecated, :call_site, :data

    def ==(other)
      other.is_a?(self.class) && other.data == data
    end
  end
  class Notification
  end

end
