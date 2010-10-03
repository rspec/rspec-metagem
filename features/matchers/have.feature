Feature: have matchers

  As an RSpec user
  I want to set readable expectations about the counts of items in a collection
  So that I can test my collection objects without having to define my own matchers

  Scenario: have(x).items on a collection
    Given a file named "have_items_spec.rb" with:
      """
      describe [1, 2, 3] do
        it { should have(3).items }
        it { should_not have(2).items }
        it { should_not have(4).items }

        it { should have_exactly(3).items }
        it { should_not have_exactly(2).items }
        it { should_not have_exactly(4).items }

        it { should have_at_least(2).items }
        it { should have_at_most(4).items }

        # deliberate failures
        it { should_not have(3).items }
        it { should have(2).items }
        it { should have(4).items }

        it { should_not have_exactly(3).items }
        it { should have_exactly(2).items }
        it { should have_exactly(4).items }

        it { should have_at_least(4).items }
        it { should have_at_most(2).items }
      end
      """
     When I run "rspec ./have_items_spec.rb"
     Then the output should contain "16 examples, 8 failures"
      And the output should contain "expected target not to have 3 items, got 3"
      And the output should contain "expected 2 items, got 3"
      And the output should contain "expected 4 items, got 3"
      And the output should contain "expected at least 4 items, got 3"
      And the output should contain "expected at most 2 items, got 3"

  Scenario: have(x).words on a String when String#words is defined
    Given a file named "have_words_spec.rb" with:
      """
      class String
        def words
          split(' ')
        end
      end

      describe "a sentence with some words" do
        it { should have(5).words }
        it { should_not have(4).words }
        it { should_not have(6).words }

        it { should have_exactly(5).words }
        it { should_not have_exactly(4).words }
        it { should_not have_exactly(6).words }

        it { should have_at_least(4).words }
        it { should have_at_most(6).words }

        # deliberate failures
        it { should_not have(5).words }
        it { should have(4).words }
        it { should have(6).words }

        it { should_not have_exactly(5).words }
        it { should have_exactly(4).words }
        it { should have_exactly(6).words }

        it { should have_at_least(6).words }
        it { should have_at_most(4).words }
      end
      """
     When I run "rspec ./have_words_spec.rb"
     Then the output should contain "16 examples, 8 failures"
      And the output should contain "expected target not to have 5 words, got 5"
      And the output should contain "expected 4 words, got 5"
      And the output should contain "expected 6 words, got 5"
      And the output should contain "expected at least 6 words, got 5"
      And the output should contain "expected at most 4 words, got 5"

