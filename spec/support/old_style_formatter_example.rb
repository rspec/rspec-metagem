class OldStyleFormatterExample

  def initialize(output)
    @output = output
  end

  def start(example_count)
    @output.puts "Started #{example_count.to_s} examples"
  end

  def example_group_started(group)
    @output.puts "Started #{group.description}"
  end

  def example_group_finished(group)
    @output.puts "Finished #{group.description}"
  end

  def example_started(example)
    @output.puts "Started #{example.full_description}"
  end

  def stop
    @output.puts "Stopped"
  end

  def message(message)
    @output.puts message
  end

  def dump_failures
    @output.puts "Failures:"
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @output.puts "\nFinished in #{duration}\n" +
                 "#{failure_count}/#{example_count} failed.\n" +
                 "#{pending_count} pending."
  end

  def dump_pending
    @output.puts "Pending:"
  end

  def seed(number)
    @output.puts "Randomized with seed #{number}"
  end

  def close
    @output.close
  end

  def example_passed(example)
    @output.print '.'
  end

  def example_pending(example)
    @output.print 'P'
  end

  def example_failed(example)
    @output.print 'F'
  end

  def start_dump
    @output.puts "Dumping!"
  end

end
