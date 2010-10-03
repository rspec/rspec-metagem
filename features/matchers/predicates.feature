Feature: predicate matchers

  As an RSpec user
  I want to set expectations based upon the predicate methods of my objects
  So that I don't have to write a custom matcher for such a simple case

  Scenario: should be_zero (based on Fixnum#zero?)
    Given a file named "should_be_zero_spec.rb" with:
      """
      describe 0 do
        it { should be_zero }
      end

      describe 7 do
        it { should be_zero } # deliberately fail
      end
      """
    When I run "rspec ./should_be_zero_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected zero? to return true, got false"

  Scenario: should_not be_empty (based on Array#empty?)
    Given a file named "should_not_be_empty_spec.rb" with:
      """
      describe Array do
        context "with 3 items" do
          it "is not empty" do
            [1, 2, 3].should_not be_empty
          end
        end

        context "with no items" do
          it "is empty, but we'll fail this spec anyway" do
            [].should_not be_empty
          end
        end
      end
      """
    When I run "rspec ./should_not_be_empty_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected empty? to return false, got true"

   Scenario: should have_key (based on Hash#has_key?)
    Given a file named "should_have_key_spec.rb" with:
      """
      describe Hash do
        context 'with :foo => 7' do
          it 'reports that it has the key :foo' do
            { :foo => 7 }.should have_key(:foo)
          end
        end

        context 'with nothing' do
          it "has no keys, but we'll fail this spec anyway" do
            {}.should have_key(:foo)
          end
        end
      end
      """
    When I run "rspec ./should_have_key_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected #has_key?(:foo) to return true, got false"

   Scenario: should_not have_all_string_keys (based on custom #has_all_string_keys? method)
     Given a file named "should_not_have_all_string_keys_spec.rb" with:
       """
       class Hash
         def has_all_string_keys?
           keys.all? { |k| String === k }
         end
       end

       describe Hash do
         context 'with symbol keys' do
           it "does not have all string keys" do
             { :foo => 7, :bar => 5 }.should_not have_all_string_keys
           end
         end

         context 'with string keys' do
           it "has all string keys, and we'll fail this spec anyway" do
             { 'foo' => 7, 'bar' => 5 }.should_not have_all_string_keys
           end
         end
       end
       """
     When I run "rspec ./should_not_have_all_string_keys_spec.rb"
     Then the output should contain "2 examples, 1 failure"
      And the output should contain "expected #has_all_string_keys?(nil) to return false, got true"

