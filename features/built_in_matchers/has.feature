Feature: has_SOMETHING() matcher

  RSpec provides a helper such that:

    * subject.should have_key(x)
    * subject.should have_item_with_name(x)

  call the appropriate predicate method.

  Scenario: have_item_with_name(x) on an object that implements #has_item_with_name?
    Given a file named "have_item_with_name_spec.rb" with:
      """
      class O
        def initialize(array)
          @array = array
        end

        def has_item_with_name?(name)
          @array.include?(name)
        end
      end

      describe O.new(%w(francois jake)) do
        it { should     have_item_with_name("francois") }
        it { should_not have_item_with_name("john") }
      end
      """

     When I run `rspec --format doc have_item_with_name_spec.rb`
     Then the examples should all pass
      And the output should contain all of these:
        | should have item with name "francois" |
        | should not have item with name "john" |
