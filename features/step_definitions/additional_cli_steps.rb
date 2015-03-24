require 'rspec/core'  # to fix annoying "undefined method `configuration' for RSpec:Module (NoMethodError)"

Then /^the output should contain all of these:$/ do |table|
  table.raw.flatten.each do |string|
    assert_partial_output(string, all_output)
  end
end

Then /^the output should not contain any of these:$/ do |table|
  table.raw.flatten.each do |string|
    expect(all_output).not_to include(string)
  end
end

Then /^the output should contain one of the following:$/ do |table|
  matching_output = table.raw.flatten.select do |string|
    all_output.include?(string)
  end

  expect(matching_output.count).to eq(1)
end

Then /^the example(?:s)? should(?: all)? pass$/ do
  step %q{the output should contain "0 failures"}
  step %q{the output should not contain "0 examples"}
  step %q{the exit status should be 0}
end

Then /^the example(?:s)? should(?: all)? fail$/ do
  step %q{the output should not contain "0 examples"}
  step %q{the output should not contain "0 failures"}
  step %q{the exit status should be 1}
  example_summary = /(\d+) examples?, (\d+) failures?/.match(all_output)
  example_count, failure_count = example_summary.captures
  expect(failure_count).to eq(example_count)
end

Then /^the process should succeed even though no examples were run$/ do
  step %q{the output should contain "0 examples, 0 failures"}
  step %q{the exit status should be 0}
end

addition_example_formatter_output = <<-EOS
Addition
  works
EOS

Then /^the output from `([^`]+)` (should(?: not)?) be in documentation format$/ do |cmd, should_or_not|
  step %Q{I run `#{cmd}`}
  step %q{the examples should all pass}
  step %Q{the output from "#{cmd}" #{should_or_not} contain "#{addition_example_formatter_output}"}
end

Then(/^the output from `([^`]+)` should indicate it ran only the subtraction file$/) do |cmd|
  step %Q{I run `#{cmd}`}
  step %q{the examples should all pass}
  step %Q{the output from "#{cmd}" should contain "1 example, 0 failures"}
  step %Q{the output from "#{cmd}" should contain "Subtraction"}
  step %Q{the output from "#{cmd}" should not contain "Addition"}
end

Then /^the backtrace\-normalized output should contain:$/ do |partial_output|
  # ruby 1.9 includes additional stuff in the backtrace,
  # so we need to normalize it to compare it with our expected output.
  normalized_output = all_output.split("\n").map do |line|
    line =~ /(^\s+# [^:]+:\d+)/ ? $1 : line # http://rubular.com/r/zDD7DdWyzF
  end.join("\n")

  expect(normalized_output).to include(partial_output)
end

Then /^the output should not contain any error backtraces$/ do
  step %q{the output should not contain "lib/rspec/core"}
end

# This step can be generalized if it's ever used to test other colors
Then /^the failing example is printed in magenta$/ do
  # \e[35m = enable magenta
  # \e[0m  = reset colors
  expect(all_output).to include("\e[35m" + "F" + "\e[0m")
end

Then /^the output from `([^`]+)` should contain "(.*?)"$/  do |cmd, expected_output|
  step %Q{I run `#{cmd}`}
  step %Q{the output from "#{cmd}" should contain "#{expected_output}"}
end

Then /^the output from `([^`]+)` should not contain "(.*?)"$/  do |cmd, expected_output|
  step %Q{I run `#{cmd}`}
  step %Q{the output from "#{cmd}" should not contain "#{expected_output}"}
end

Given /^I have a brand new project with no files$/ do
  in_current_dir do
    expect(Dir["**/*"]).to eq([])
  end
end

Given /^I have run `([^`]*)`$/ do |cmd|
  fail_on_error = true
  run_simple(unescape(cmd), fail_on_error)
end

Given(/^a vendored gem named "(.*?)" containing a file named "(.*?)" with:$/) do |gem_name, file_name, file_contents|
  gem_dir = "vendor/#{gem_name}-1.2.3"
  step %Q{a file named "#{gem_dir}/#{file_name}" with:}, file_contents
  set_env('RUBYOPT', ENV['RUBYOPT'] + " -I#{gem_dir}/lib")
end

When "I accept the recommended settings by removing `=begin` and `=end` from `spec/spec_helper.rb`" do
  in_current_dir do
    spec_helper = File.read("spec/spec_helper.rb")
    expect(spec_helper).to include("=begin", "=end")

    to_keep = spec_helper.lines.reject do |line|
      line.start_with?("=begin") || line.start_with?("=end")
    end

    File.open("spec/spec_helper.rb", "w") { |f| f.write(to_keep.join) }
    expect(File.read("spec/spec_helper.rb")).not_to include("=begin", "=end")
  end
end

When /^I create "([^"]*)" with the following content:$/ do |file_name, content|
  write_file(file_name, content)
end

Given(/^I have run `([^`]*)` once, resulting in "([^"]*)"$/) do |command, output_snippet|
  step %Q{I run `#{command}`}
  step %Q{the output from "#{command}" should contain "#{output_snippet}"}
end

When(/^I fix "(.*?)" by replacing "(.*?)" with "(.*?)"$/) do |file_name, original, replacement|
  in_current_dir do
    contents = File.read(file_name)
    expect(contents).to include(original)
    fixed = contents.sub(original, replacement)
    File.open(file_name, "w") { |f| f.write(fixed) }
  end
end

Then(/^it should fail with "(.*?)"$/) do |snippet|
  assert_failing_with(snippet)
end

Given(/^I have not configured `example_status_persistence_file_path`$/) do
  in_current_dir do
    return unless File.exist?("spec/spec_helper.rb")
    return unless File.read("spec/spec_helper.rb").include?("example_status_persistence_file_path")
    File.open("spec/spec_helper.rb", "w") { |f| f.write("") }
  end
end

Given(/^files "(.*?)" through "(.*?)" with an unrelated passing spec in each file$/) do |file1, file2|
  index_1 = Integer(file1[/\d+/])
  index_2 = Integer(file2[/\d+/])
  pattern = file1.sub(/\d+/, '%s')

  index_1.upto(index_2) do |index|
    write_file(pattern % index, <<-EOS)
      RSpec.describe "Spec file #{index}" do
        example { }
      end
    EOS
  end
end
