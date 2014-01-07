class OldStyleFormatterExample
  include ::RSpec::Core::Formatters::Helpers
  attr_reader :example_group, :duration, :examples, :output
  attr_reader :example_count, :pending_count, :failure_count
  attr_reader :failed_examples, :pending_examples

  def initialize(output)
    @output = output || StringIO.new
    @example_count = @pending_count = @failure_count = 0
    @examples = []
    @failed_examples = []
    @pending_examples = []
    @example_group = nil
  end

  def start(example_count)
    @example_count = example_count
  end

  def example_group_started(group)
    @example_group = group
  end

  def example_group_finished(group)
    @example_group = group
  end

  def example_started(example)
    examples << example
  end

  def stop
  end

  def message(message)
    output.puts message
  end

  def dump_failures
    return if failed_examples.empty?
    output.puts
    output.puts "Failures:"
    failed_examples.each_with_index do |example, index|
      output.puts example.full_description
    end
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    @duration = duration
    @example_count = example_count
    @failure_count = failure_count
    @pending_count = pending_count
    output.puts "\nFinished in #{duration}\n"
  end

  def dump_profile
    'PROFILE DISABLED'
  end

  def dump_pending
    unless pending_examples.empty?
      output.puts
      output.puts "Pending:"
      pending_examples.each do |pending_example|
        output.puts pending_example.full_description
      end
    end
  end

  def seed(number)
    output.puts
    output.puts "Randomized with seed #{number}"
    output.puts
  end

  def close
    output.close if IO === output && output != $stdout
  end

  def example_passed(example)
    output.print '.'
  end

  def example_pending(example)
    @pending_examples << example
    output.print '*'
  end

  def example_failed(example)
    @failed_examples << example
    output.print 'F'
  end

  def start_dump
    output.puts
  end

end
