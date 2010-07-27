module RSpec::Core
  class Reporter
    def initialize(formatter)
      @formatter = formatter
    end

    def report(count)
      @formatter.start(count)
      begin
        yield self
        @formatter.stop
        @formatter.start_dump
        @formatter.dump_summary(duration, example_count, failure_count, pending_count)
        @formatter.dump_pending
        @formatter.dump_failures
      ensure
        @formatter.close
      end
    end

    def method_missing(method, *args, &block)
      @formatter.send method, *args, &block
    end
  end
end
