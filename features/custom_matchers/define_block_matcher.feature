Feature: define a matcher supporting block expectations

  When you wish to support block expectations (e.g. `expect { ... }.to matcher`) with
  your custom matchers you must specify this. You can do this manually (or determinately
  based on some logic) by defining a `supports_block_expectation?` method or by using
  the DSL's `supports_block_expectations` shortcut method.

  Scenario: define a block matcher
    Given a file named "block_matcher_spec.rb" with:
      """ruby
      RSpec::Matchers.define :support_blocks do
        match do |actual|
          actual.is_a? Proc
        end

        supports_block_expectations
      end

      RSpec.describe "a custom block matcher" do
        specify { expect { }.to support_blocks }
      end
      """
    When I run `rspec ./block_matcher_spec.rb`
    Then the example should pass
