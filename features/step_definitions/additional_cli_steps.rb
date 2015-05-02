# Useful for when the output is slightly different on different versions of ruby
Then /^the output should contain "([^"]*)" or "([^"]*)"$/ do |string1, string2|
  unless [string1, string2].any? { |s| all_output.include?(s) }
    fail %Q{Neither "#{string1}" or "#{string2}" were found in:\n#{all_output}}
  end
end

Then /^the output should contain all of these:$/ do |table|
  table.raw.flatten.each do |string|
    assert_partial_output(string, all_output)
  end
end

Then /^the example(?:s)? should(?: all)? pass$/ do
  step %q{the output should contain "0 failures"}
  step %q{the exit status should be 0}
end

Then /^the example should fail$/ do
  step %q{the output should contain "1 failure"}
  step %q{the exit status should not be 0}
end

Then(/^it should fail listing all the failures:$/) do |string|
  step %q{the exit status should not be 0}
  expect(normalize_whitespace_and_backtraces(all_output)).to include(normalize_whitespace_and_backtraces(string))
end

module WhitespaceNormalization
  def normalize_whitespace_and_backtraces(text)
    text.lines.map { |line| line.sub(/\s+$/, '').sub(/:in .*$/, '') }.join
  end
end

World(WhitespaceNormalization)
