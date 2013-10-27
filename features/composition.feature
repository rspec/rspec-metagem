Feature: matcher composition

  Matchers can be composed to make complex expectations.

  Scenario: Use `and` to chain expectations
    Given a file named "chained_assertions.rb" with:
      """ruby
      describe "composing matchers" do

        subject do
          {:foo => 'bar', :other => rand(3)}
        end

        it "pass when both are true" do
          expect(subject).to include(:foo => 'bar').and(include(:other))
        end

        it "deliberate failure on the second matcher" do
          expect(subject).to include(:foo => 'bar').and(include(:not_me))
        end

        it "deliberate failure on the first matcher" do
          expect(subject).to include(:foo => 'NOTME').and(include(:other))
        end
      end
      """
    When I run `rspec chained_assertions.rb`
    Then the output should contain "3 examples, 2 failures"

  Scenario: Use `or` to chain expectations
    Given a file named "not_predictable.rb" with:
      """ruby
      describe "a random number" do
        subject do
          rand(2)
        end

        it "has one of the two available values" do
          expect(subject).to eq(0).or(eq(1))
        end
      end
      """
    When I run `rspec not_predictable.rb`
    Then the example should pass
