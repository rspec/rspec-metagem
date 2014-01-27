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

  DeprecationNotification = Struct.new(:message, :replacement, :deprecated, :call_site) do
    def self.from_hash(data)
      new data[:message], data[:replacement], data[:deprecated], data[:call_site]
    end
  end

  class Notification
  end

end
