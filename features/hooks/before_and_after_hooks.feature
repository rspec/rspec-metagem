Feature: before and after hooks

  As a developer using RSpec
  I want to execute arbitrary code before and after each example
  So that I can control the environment in which it is run

    This is supported by the before and after methods which each take a symbol
    indicating the scope, and a block of code to execute.

    before(:each) blocks are run before each example
    before(:all) blocks are run once before all of the examples in a group

    after(:each) blocks are run after each example
    after(:all) blocks are run once after all of the examples in a group

    Before and after blocks are called in the following order:
      before all
      before each
      after each
      after all

    Before and after blocks can be defined in the example groups to which they
    apply or in a configuration. When defined in a configuration, they can be
    applied to all groups or subsets of all groups defined by example group
    types.

  Scenario: define before(:each) block
    Given a file named "before_each_spec.rb" with:
      """
      require "rspec/expectations"

      class Thing
        def widgets
          @widgets ||= []
        end
      end

      describe Thing do
        before(:each) do
          @thing = Thing.new
        end

        describe "initialized in before(:each)" do
          it "has 0 widgets" do
            @thing.should have(0).widgets
          end

          it "can get accept new widgets" do
            @thing.widgets << Object.new
          end

          it "does not share state across examples" do
            @thing.should have(0).widgets
          end
        end
      end
      """
    When I run "rspec ./before_each_spec.rb"
    Then I should see "3 examples, 0 failures"

  Scenario: define before(:all) block in example group
    Given a file named "before_all_spec.rb" with:
      """
      require "rspec/expectations"

      class Thing
        def widgets
          @widgets ||= []
        end
      end
  
      describe Thing do
        before(:all) do
          @thing = Thing.new
        end
  
        describe "initialized in before(:all)" do
          it "has 0 widgets" do
            @thing.should have(0).widgets
          end
  
          it "can get accept new widgets" do
            @thing.widgets << Object.new
          end
  
          it "shares state across examples" do
            @thing.should have(1).widgets
          end
        end
      end
      """
    When I run "rspec ./before_all_spec.rb"
    Then I should see "3 examples, 0 failures"

    When I run "rspec ./before_all_spec.rb:15"
    Then I should see "1 example, 0 failures"

  Scenario: define before and after blocks in configuration
    Given a file named "befores_in_configuration_spec.rb" with:
      """
      require "rspec/expectations"

      RSpec.configure do |config|
        config.before(:each) do
          @before_each = "before each"
        end
        config.before(:all) do
          @before_all = "before all"
        end
      end
  
      describe "stuff in before blocks" do
        describe "with :all" do
          it "should be available in the example" do
            @before_all.should == "before all"
          end
        end
        describe "with :each" do
          it "should be available in the example" do
            @before_each.should == "before each"
          end
        end
      end
      """
    When I run "rspec ./befores_in_configuration_spec.rb"
    Then I should see "2 examples, 0 failures"

  Scenario: before/after blocks are run in order
    Given a file named "ensure_block_order_spec.rb" with:
      """
      require "rspec/expectations"

      describe "before and after callbacks" do
        before(:all) do
          puts "before all"
        end
  
        before(:each) do
          puts "before each"
        end
  
        after(:each) do
          puts "after each"
        end
  
        after(:all) do
          puts "after all"
        end
  
        it "gets run in order" do
  
        end
      end
      """
    When I run "rspec ./ensure_block_order_spec.rb"
    Then I should see matching /before all\nbefore each\nafter each\n.after all/
  
  Scenario: before/after all blocks are run once
    Given a file named "before_and_after_all_spec.rb" with:
      """
      describe "before and after callbacks" do
        before(:all) do
          puts "outer before all"
        end
  
        example "in outer group" do
        end

        after(:all) do
          puts "outer after all"
        end

        describe "nested group" do
          before(:all) do
            puts "inner before all"
          end
          
          example "in nested group" do
          end

          after(:all) do
            puts "inner after all"
          end
        end

      end
      """
    When I run "rspec ./before_and_after_all_spec.rb"
    Then I should see "2 examples, 0 failures"
    Then I should see matching /outer before all\n.inner before all\n.inner after all\nouter after all\n\n\n\nFinished/

    When I run "rspec ./before_and_after_all_spec.rb:14"
    Then I should see "1 example, 0 failures"
    Then I should see matching /outer before all\ninner before all\n.inner after all\nouter after all\n\n\n\nFinished/

    When I run "rspec ./before_and_after_all_spec.rb:6"
    Then I should see "1 example, 0 failures"
    Then I should see matching /outer before all\n.outer after all\n\n\n\nFinished/

  Scenario: before/after all blocks have access to state
    Given a file named "before_and_after_all_spec.rb" with:
      """
      describe "before and after callbacks" do
        before(:all) do
          @outer_state = "set in outer before all"
        end

        example "in outer group" do
          @outer_state.should eq("set in outer before all")
        end

        describe "nested group" do
          before(:all) do
            @inner_state = "set in inner before all"
          end

          example "in nested group" do
            @outer_state.should eq("set in outer before all")
            @inner_state.should eq("set in inner before all")
          end

          after(:all) do
            @inner_state.should eq("set in inner before all")
          end
        end

        after(:all) do
          # p @outer_state.nil?
          @outer_state.should eq("set in outer before all")
        end
      end
      """
    When I run "rspec ./before_and_after_all_spec.rb"
    Then I should see "2 examples, 0 failures"

  Scenario: exception in before(:each) is captured and reported as failure
    Given a file named "error_in_before_each_spec.rb" with:
      """
      describe "error in before(:each)" do
        before(:each) do
          raise "this error"
        end

        it "is reported as failure" do
        end
      end
      """
    When I run "rspec ./error_in_before_each_spec.rb"
    Then I should see "1 example, 1 failure"
    And I should see "this error"

@wip
  Scenario: exception in before(:all) is captured and reported as failure
    Given a file named "error_in_before_all_spec.rb" with:
      """
      describe "error in before(:all)" do
        before(:all) do
          raise "this error"
        end

        it "is reported as failure" do
        end
      end
      """
    When I run "rspec ./error_in_before_all_spec.rb"
    Then I should see "1 example, 1 failure"
    And I should see "this error"
