Feature: define scoped alias matcher rspec

  You can define custom matchers when using rspec-expectations inside of `describe` blocks.

  Scenario: define a matcher with default messages
    Given a file named "test_untrue.rb" with:
      """ruby
      RSpec.describe "with scoped matcher" do
        alias_matcher :be_untrue, :be_falsy

        example do
          expect(false).to be_untrue
        end
      end

      RSpec.describe "without scoped matcher" do
        example do
          expect(false).to be_untrue
        end
      end
      """
    When I run `rspec ./test_untrue.rb`
    Then it should fail with:
      """
      Failures:

        1) without scoped matcher should be untrue
           Failure/Error: expect(false).to be_untrue
             expected false to respond to `untrue?`
      """
