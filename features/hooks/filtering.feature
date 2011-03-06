Feature: filters

  `before`/`after`/`around` hooks defined in the RSpec configuration block can
  be filtered using metadata.  Arbitrary metadata can be applied to an example
  or example group, and used to make a hook only apply to examples with the
  given metadata.

  Scenario: filter `before(:each)` hooks using arbitrary metadata
    Given a file named "filter_before_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:each, :foo => :bar) do
          invoked_hooks << :before_each_foo_bar
        end
      end

      describe "a filtered before :each hook" do
        let(:invoked_hooks) { [] }

        describe "group without matching metadata" do
          it "does not run the hook" do
            invoked_hooks.should be_empty
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            invoked_hooks.should == [:before_each_foo_bar]
          end
        end

        describe "group with matching metadata", :foo => :bar do
          it "runs the hook" do
            invoked_hooks.should == [:before_each_foo_bar]
          end
        end
      end
      """
    When I run "rspec filter_before_each_hooks_spec.rb"
    Then the examples should all pass

  Scenario: filter `after(:each)` hooks using arbitrary metadata
    Given a file named "filter_after_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.after(:each, :foo => :bar) do
          raise "boom!"
        end
      end

      describe "a filtered after :each hook" do
        describe "group without matching metadata" do
          it "does not run the hook" do
            # should pass
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            # should fail
          end
        end

        describe "group with matching metadata", :foo => :bar do
          it "runs the hook" do
            # should fail
          end
        end
      end
      """
    When I run "rspec filter_after_each_hooks_spec.rb"
    Then the output should contain "3 examples, 2 failures"

  Scenario: filter around(:each) hooks using arbitrary metadata
    Given a file named "filter_around_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.around(:each, :foo => :bar) do |example|
          order << :before_around_each_foo_bar
          example.run
          order.should == [:before_around_each_foo_bar, :example]
        end
      end

      describe "a filtered around(:each) hook" do
        let(:order) { [] }

        describe "a group without matching metadata" do
          it "does not run the hook" do
            order.should be_empty
          end

          it "runs the hook for an example with matching metadata", :foo => :bar do
            order.should == [:before_around_each_foo_bar]
            order << :example
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook for an example with matching metadata", :foo => :bar do
            order.should == [:before_around_each_foo_bar]
            order << :example
          end
        end
      end
      """
    When I run "rspec filter_around_each_hooks_spec.rb"
    Then the examples should all pass

  Scenario: filter before(:all) hooks using arbitrary metadata
    Given a file named "filter_before_all_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:all, :foo => :bar) { @hook = :before_all_foo_bar }
      end

      describe "a filtered before(:all) hook" do
        describe "a group without matching metadata" do
          it "does not run the hook" do
            @hook.should be_nil
          end

          describe "a nested subgroup with matching metadata", :foo => :bar do
            it "runs the hook" do
              @hook.should == :before_all_foo_bar
            end
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook" do
            @hook.should == :before_all_foo_bar
          end

          describe "a nested subgroup" do
            it "runs the hook" do
              @hook.should == :before_all_foo_bar
            end
          end
        end
      end
      """
    When I run "rspec filter_before_all_hooks_spec.rb"
    Then the examples should all pass

  Scenario: filter after(:all) hooks using arbitrary metadata
    Given a file named "filter_after_all_hooks_spec.rb" with:
      """
      example_msgs = []

      RSpec.configure do |config|
        config.after(:all, :foo => :bar) do
          puts "after :all"
        end
      end

      describe "a filtered after(:all) hook" do
        describe "a group without matching metadata" do
          it "does not run the hook" do
            puts "unfiltered"
          end
        end

        describe "a group with matching metadata", :foo => :bar do
          it "runs the hook" do
            puts "filtered 1"
          end
        end

        describe "another group without matching metadata" do
          describe "a nested subgroup with matching metadata", :foo => :bar do
            it "runs the hook" do
              puts "filtered 2"
            end
          end
        end
      end
      """
    When I run "rspec filter_after_all_hooks_spec.rb"
    Then the examples should all pass
    And the output should contain:
      """
      unfiltered
      .filtered 1
      .after :all
      filtered 2
      .after :all
      """
