Feature: Excluding lines from the backtrace

  To reduce the noise when diagnosing , RSpec excludes matching lines from
  backtraces. The default exclusion patterns are:

    /\/lib\d*\/ruby\//,
    /org\/jruby\//,
    /bin\//,
    /gems/,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/

  This list can be modified or replaced with the `backtrace_exclusion_patterns`
  option. Additionally, rspec can be run with the `--backtrace` option to skip
  backtrace cleaning entirely.

  Scenario: using default backtrace_exclusion_patterns
    Given a file named "spec/failing_spec.rb" with:
    """ruby
    describe "2 + 2" do
      it "is 5" do
        expect(2+2).to eq(5)
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    And the output should not contain "lib/rspec/expectations"

  Scenario: replacing backtrace_exclusion_patterns
    Given a file named "spec/spec_helper.rb" with:
    """ruby
    RSpec.configure do |config|
      config.backtrace_exclusion_patterns = [
        /spec_helper/
      ]
    end

    def foo
      "bar"
    end
    """
    And a file named "spec/example_spec.rb" with:
    """ruby
    require 'spec_helper'
    describe "foo" do
      it "returns baz" do
        expect(foo).to eq("baz")
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    And the output should contain "lib/rspec/expectations"

  Scenario: appending to backtrace_exclusion_patterns
    Given a file named "spec/matchers/be_baz_matcher.rb" with:
    """ruby
    RSpec::Matchers.define :be_baz do |_|
      match do |actual|
        actual == "baz"
      end
    end
    """
    And a file named "spec/example_spec.rb" with:
    """ruby
    RSpec.configure do |config|
      config.backtrace_exclusion_patterns << /be_baz_matcher/
    end

    describe "bar" do
      it "is baz" do
        expect("bar").to be_baz
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    But the output should not contain "be_baz_matcher"
    And the output should not contain "lib/rspec/expectations"

  Scenario: running rspec with the --backtrace option
    Given a file named "spec/matchers/be_baz_matcher.rb" with:
    """ruby
    RSpec::Matchers.define :be_baz do |_|
      match do |actual|
        actual == "baz"
      end
    end
    """
    And a file named "spec/example_spec.rb" with:
    """ruby
    RSpec.configure do |config|
      config.backtrace_exclusion_patterns << /be_baz_matcher/
    end

    describe "bar" do
      it "is baz" do
        expect("bar").to be_baz
      end
    end
    """
    When I run `rspec --backtrace`
    Then the output should contain "1 example, 1 failure"
    And the output should not contain "be_baz_matcher"
