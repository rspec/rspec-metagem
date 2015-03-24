Feature: Bisect

  RSpec's `--order random` and `--seed` options help surface flickering examples that only fail when one or more other examples are executed first. It can be very difficult to isolate the exact combination of examples that triggers the failure. The `--bisect` flag helps solve that problem.

  Pass the `--bisect` option (in addition to `--seed` any other options) and RSpec will repeatedly run subsets of your suite in order to isolate the minimal set of examples that reproduce the failure.

  Scenario: Use `--bisect` flag to create a minimal repro case for the ordering dependency
    Given a file named "lib/calculator.rb" with:
      """ruby
      class Calculator
        def self.add(x, y)
          x + y
        end
      end
      """
    And a file named "spec/calculator_1_spec.rb" with:
      """ruby
      require 'calculator'

      RSpec.describe "Calculator" do
        it 'adds numbers' do
          expect(Calculator.add(1, 2)).to eq(3)
        end
      end
      """
    And files "spec/calculator_2_spec.rb" through "spec/calculator_9_spec.rb" with an unrelated passing spec in each file
    And a file named "spec/calculator_10_spec.rb" with:
      """ruby
      require 'calculator'

      RSpec.describe "Monkey patched Calculator" do
        it 'does screwy math' do
          # monkey patching `Calculator` affects examples that are
          # executed after this one!
          def Calculator.add(x, y)
            x - y
          end

          expect(Calculator.add(5, 10)).to eq(-5)
        end
      end
      """
    When I run `rspec --seed 1234`
    Then the output should contain "10 examples, 1 failure"
    When I run `rspec --seed 1234 --bisect`
    Then the output should contain "rspec ./spec/calculator_10_spec.rb[1:1] ./spec/calculator_1_spec.rb[1:1] --seed 1234"
    When I run `rspec ./spec/calculator_10_spec.rb[1:1] ./spec/calculator_1_spec.rb[1:1] --seed 1234`
    Then the output should contain "2 examples, 1 failure"
