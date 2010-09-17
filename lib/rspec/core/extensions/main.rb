def describe(*args, &example_group_block)
  args << {} unless args.last.is_a?(Hash)
  args.last.update :caller => caller(1)
  RSpec::Core::ExampleGroup.describe(*args, &example_group_block)
end

def method_missing(m, *a, &b)
  if m == :debugger
    RSpec.configuration.error_stream.puts "debugger statement ignored, use -d or --debug option to enable debugging\n#{caller(0)[1]}"
  else
    super
  end
end
