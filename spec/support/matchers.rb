Rspec::Matchers.define :map_specs do |specs|
  match do |autotest|
    @specs = specs
    @autotest = prepare(autotest)
    autotest.test_files_for(@file) == specs
  end

  chain :to do |file|
    @file = file
  end

  failure_message_for_should do
    "expected #{@autotest.class} to map #{@specs.inspect} to #{@file.inspect}\ngot #{@actual.inspect}"
  end

  def prepare(autotest)
    find_order = @specs.dup << @file
    autotest.instance_eval { @find_order = find_order }
    autotest
  end
end
