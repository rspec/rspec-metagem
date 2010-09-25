Feature: exclusion filters
  
  Scenario: exclude one example
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end

      describe "something" do
        it "does one thing" do
        end

        it "does another thing", :broken => true do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "does one thing"
    And the output should not contain "does another thing"

  Scenario: exclude one group
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end
  
      describe "group 1", :broken => true do
        it "group 1 example 1" do
        end
  
        it "group 1 example 2" do
        end
      end
  
      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "group 2 example 1"
    And  the output should not contain "group 1 example 1"
    And  the output should not contain "group 1 example 2"
  
  Scenario: exclude all groups
    Given a file named "spec/sample_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end
  
      describe "group 1", :broken => true do
        before(:all) do
          raise "you should not see me"
        end
        
        it "group 1 example 1" do
        end
  
        it "group 1 example 2" do
        end
      end
  
      describe "group 2", :broken => true do
        before(:each) do
          raise "you should not see me"
        end
        
        it "group 2 example 1" do
        end
      end
      """
    When I run "rspec ./spec/sample_spec.rb --format doc"
    Then the output should contain "No examples were matched. Perhaps {:broken=>true} is excluding everything?"
    And  the output should contain "0 examples, 0 failures"
    And  the output should not contain "group 1"
    And  the output should not contain "group 2"

  Scenario: before/after(:all) hook in excluded example group
    Given a file named "spec/before_after_all_exclusion_filter_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end

      describe "group 1" do
        before(:all) { puts "before all in focused group" }
        after(:all)  { puts "after all in focused group"  }

        it "group 1 example" do
        end
      end

      describe "group 2", :broken => true do
        before(:all) { puts "before all in unfocused group" }
        after(:all)  { puts "after all in unfocused group"  }

        context "context 1" do
          it "group 2 context 1 example 1" do
          end
        end
      end
      """
    When I run "rspec ./spec/before_after_all_exclusion_filter_spec.rb"
    Then the output should contain "before all in focused group"
     And the output should contain "after all in focused group"
     And the output should not contain "before all in unfocused group"
     And the output should not contain "after all in unfocused group"
