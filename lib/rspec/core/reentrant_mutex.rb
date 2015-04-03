module RSpec
  module Core
    # Allows a thread to lock out other threads from a critical section of code,
    # while allowing the thread with the lock to reenter that section.
    #
    # Based on Monitor as of 2.2 - https://github.com/ruby/ruby/blob/eb7ddaa3a47bf48045d26c72eb0f263a53524ebc/lib/monitor.rb#L9
    #
    # Depends on Mutex, but Mutex is only available as part of core since 1.9.1:
    #   exists - http://ruby-doc.org/core-1.9.1/Mutex.html
    #   dne    - http://ruby-doc.org/core-1.9.0/Mutex.html
    #
    # @private
    class ReentrantMutex
      def initialize
        @owner = nil
        @count = 0
        @mutex = MUTEX.new
      end

      def synchronize
        enter
        yield
      ensure
        exit
      end

    private

      def enter
        @mutex.lock if @owner != Thread.current
        @owner = Thread.current
        @count += 1
      end

      def exit
        @count -= 1
        return unless @count == 0
        @owner = nil
        @mutex.unlock
      end
    end

    # @private
    # :nocov:
    # This can be deleted once support for 1.8.7 is dropped
    MUTEX = if defined? ::Mutex
              # On 1.9 and up, this is in core, so we just use the real one
              ::Mutex
            else
              # On 1.8.7, it's in the stdlib.
              # We don't want to load the stdlib, b/c this is a test tool, and can affect the test environment,
              # causing tests to pass where they should fail.
              #
              # So we're transcribing/modifying it from https://github.com/ruby/ruby/blob/v1_8_7_374/lib/thread.rb#L56
              # Some methods we don't need are deleted.
              # Anything I don't understand (there's quite a bit, actually) is left in.
              # Some formating changes are made to appease the robot overlord:
              #   https://travis-ci.org/rspec/rspec-core/jobs/54410874
              Class.new do
                def initialize
                  @waiting = []
                  @locked = false
                  @waiting.taint
                  taint
                end

                def lock
                  while Thread.critical = true && @locked
                    @waiting.push Thread.current
                    Thread.stop
                  end
                  @locked = true
                  Thread.critical = false
                  self
                end

                def unlock
                  return unless @locked
                  Thread.critical = true
                  @locked = false
                  begin
                    t = @waiting.shift
                    t.wakeup if t
                  rescue ThreadError
                    retry
                  end
                  Thread.critical = false
                  begin
                    t.run if t
                  rescue ThreadError
                    :noop
                  end
                  self
                end

                def synchronize
                  lock
                  begin
                    yield
                  ensure
                    unlock
                  end
                end
              end
            end
  end
end
