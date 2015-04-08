FakeBisectRunner = Struct.new(:all_ids, :always_failures, :dependent_failures) do
  def original_cli_args
    []
  end

  def original_results
    failures = always_failures | dependent_failures.keys
    RSpec::Core::Formatters::BisectFormatter::RunResults.new(all_ids, failures.sort)
  end

  def run(ids)
    failures = ids & always_failures
    dependent_failures.each do |failing_example, depends_upon|
      failures << failing_example if ids.include?(depends_upon)
    end

    RSpec::Core::Formatters::BisectFormatter::RunResults.new(ids.sort, failures.sort)
  end

  def repro_command_from(locations)
    "rspec #{locations.sort.join(' ')}"
  end
end
