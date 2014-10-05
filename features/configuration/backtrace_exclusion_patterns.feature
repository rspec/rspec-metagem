Feature: Excluding lines from the backtrace

  To reduce the noise when diagnosing failures, RSpec excludes matching lines
  from backtraces. The default exclusion patterns are:

  ```ruby
  /\/lib\d*\/ruby\//,
  /org\/jruby\//,
  /bin\//,
  /lib\/rspec\/(core|expectations|matchers|mocks)/
  ```

  This list can be modified or replaced with the `backtrace_exclusion_patterns`
  option. Additionally, `rspec` can be run with the `--backtrace` option to skip
  backtrace cleaning entirely.

  In addition, if you want to filter out backtrace lines from specific gems, you
  can use `config.filter_gems_from_backtrace`.

  Scenario: Using default `backtrace_exclusion_patterns`
    Given a file named "spec/failing_spec.rb" with:
    """ruby
    RSpec.describe "2 + 2" do
      it "is 5" do
        expect(2+2).to eq(5)
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    And the output should not contain "lib/rspec/expectations"

  Scenario: Replacing `backtrace_exclusion_patterns`
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
    RSpec.describe "foo" do
      it "returns baz" do
        expect(foo).to eq("baz")
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    And the output should contain "lib/rspec/expectations"

  Scenario: Appending to `backtrace_exclusion_patterns`
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

    RSpec.describe "bar" do
      it "is baz" do
        expect("bar").to be_baz
      end
    end
    """
    When I run `rspec`
    Then the output should contain "1 example, 1 failure"
    But the output should not contain "be_baz_matcher"
    And the output should not contain "lib/rspec/expectations"

  Scenario: Running `rspec` with the `--backtrace` option
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

    RSpec.describe "bar" do
      it "is baz" do
        expect("bar").to be_baz
      end
    end
    """
    When I run `rspec --backtrace`
    Then the output should contain "1 example, 1 failure"
    And the output should not contain "be_baz_matcher"

  Scenario: Using `filter_gems_from_backtrace` to filter the named gem
    Given a vendored gem named "my_gem" containing a file named "lib/my_gem.rb" with:
      """ruby
      class MyGem
        def self.do_amazing_things!
          # intentional bug to trigger an exception
          impossible_math = 10 / 0
          "10 div 0 is: #{impossible_math}"
        end
      end
      """
    And a file named "spec/use_my_gem_spec.rb" with:
      """ruby
      require 'my_gem'

      RSpec.describe "Using my_gem" do
        it 'does amazing things' do
          expect(MyGem.do_amazing_things!).to include("10 div 0 is")
        end
      end
      """
    And a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure do |config|
        config.filter_gems_from_backtrace "my_gem"
      end
      """
    Then the output from `rspec` should contain "vendor/my_gem-1.2.3/lib/my_gem.rb:4:in `do_amazing_things!'"
    But the output from `rspec --require spec_helper` should not contain "vendor/my_gem-1.2.3/lib/my_gem.rb:4:in `do_amazing_things!'"
