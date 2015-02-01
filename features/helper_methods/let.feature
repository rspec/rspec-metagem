Feature: let and let!

  Use `let` to define a memoized helper method. The value will be cached across
  multiple calls in the same example but not across examples.

  Note that `let` is lazy-evaluated: it is not evaluated until the first time
  the method it defines is invoked. You can use `let!` to force the method's
  invocation before each example.

  Scenario: Use `let` to define memoized helper method
    Given a file named "let_spec.rb" with:
      """ruby
      $count = 0
      RSpec.describe "let" do
        let(:count) { $count += 1 }

        it "memoizes the value" do
          expect(count).to eq(1)
          expect(count).to eq(1)
        end

        it "is not cached across examples" do
          expect(count).to eq(2)
        end
      end
      """
    When I run `rspec let_spec.rb`
    Then the examples should all pass

  Scenario: Use `let!` to define a memoized helper method that is called in a `before` hook
    Given a file named "let_bang_spec.rb" with:
      """ruby
      $count = 0
      RSpec.describe "let!" do
        invocation_order = []

        let!(:count) do
          invocation_order << :let!
          $count += 1
        end

        it "calls the helper method in a before hook" do
          invocation_order << :example
          expect(invocation_order).to eq([:let!, :example])
          expect(count).to eq(1)
        end
      end
      """
    When I run `rspec let_bang_spec.rb`
    Then the examples should all pass

  Scenario: Use --threadsafe to set `RSpec.configuration.threadsafe` (defaults to true)
    Given a file named "let_threadsafe.rb" with:
      """ruby
      require 'thread'
      accesses = Queue.new
      turns    = Queue.new

      RSpec.describe "threadsafe let" do
        let :resource do
          turns.shift
          accesses << :from_let
        end

        it "will only ever access the let block once" do
          first_access  = Thread.new { resource }
          second_access = Thread.new { resource }
          loop do
            Thread.pass
            break if first_access.stop? && second_access.stop?
          end
          turns << nil
          turns << nil
          first_access.join
          second_access.join
          accesses << :from_example
          expect(accesses.shift).to eq :from_let
          expect(accesses.shift).to eq :from_example
        end
      end
      """
    When I run `rspec let_threadsafe.rb --threadsafe`
    Then the examples should all pass

    When I run `rspec let_threadsafe.rb --no-threadsafe`
    Then the output should contain "1 example, 1 failure"

    When I run `rspec let_threadsafe.rb`
    Then the examples should all pass
