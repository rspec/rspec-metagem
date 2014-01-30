require 'rspec/core/formatters/base_text_formatter'

class LegacyFormatterUsingSubClassing < RSpec::Core::Formatters::BaseTextFormatter

  def initialize(output)
    super nil
    @output = output
  end

  def start(example_count)
    super
    @output.puts "Started #{example_count.to_s} examples"
  end

  def example_group_started(group)
    super
    @output.puts "Started #{group.description}"
  end

  def example_group_finished(group)
    super
    @output.puts "Finished #{group.description}"
  end

  def example_started(example)
    super
    @output.puts "Started #{example.full_description}"
  end

  def stop
    super
    @output.puts "Stopped"
  end

  def message(message)
    super
    @output.puts message
  end

  def dump_failures
    super
    @output.puts "Failures:"
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    super
    @output.puts "\nFinished in #{duration}\n" +
                 "#{failure_count}/#{example_count} failed.\n" +
                 "#{pending_count} pending."
  end

  def dump_pending
    super
    @output.puts "Pending:"
  end

  def seed(number)
    super
    @output.puts "Randomized with seed #{number}"
  end

  def close
    super
    @output.close
  end

  def example_passed(example)
    super
    @output.print '.'
  end

  def example_pending(example)
    super
    @output.print 'P'
  end

  def example_failed(example)
    super
    @output.print 'F'
  end

  def start_dump
    super
    @output.puts "Dumping!"
  end

end
