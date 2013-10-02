Feature: matcher composition

  Matchers can be composed to make complex expectations. For example we can
  specify that something should be a `Hash` and also that it contains certains
  keys.

  Scenario: Use `and` to chain expectations
    Given a file named "chained_assertions.rb" with:
      """ruby
      describe "composing matchers" do
        it "pass when both are true" do
          expect(:foo => 'bar').to be_kind_of(Hash).and(include(:foo))
        end

        it "deliberate failure on the second matcher" do
          expect(:foo => 'bar').to be_kind_of(Hash).and(include(:not_included))
        end

        it "deliberate failure on the first matcher" do
          expect(:foo => 'bar').to be_kind_of(Array).and(include(:foo))
        end
      end
      """
    When I run `rspec chained_assertions.rb`
    Then the output should contain "3 examples, 2 failures"
