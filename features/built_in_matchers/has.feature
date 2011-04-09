Feature: has_(predicate) matcher

  RSpec provides a predicate matcher such that:

    * obj.should have_key(x)
    * obj.should have_item_with_name(x)

  will set an expectation on the appropriate predicate method:

	* obj.has_key?(x)
	* obj.has_item_with_name?(x)

  Scenario: predicate method usage
    Given a file named "have_item_with_name_spec.rb" with:
      """
      class Array
        def has_item_with_name?(name)
          self.include?(name)
        end
      end

      describe ["francois", "jake"] do
        it { should     have_item_with_name("francois") }
        it { should_not have_item_with_name("john") }
      end
      """

     When I run `rspec --format doc have_item_with_name_spec.rb`
     Then the examples should all pass
      And the output should contain all of these:
        | should have item with name "francois" |
        | should not have item with name "john" |
