Feature: Global Hook Filtering

  Before/After/Around hooks defined in the RSpec configuration block
  can be filtered using metadata.  Arbitrary metadata can be applied
  to an example or example group, and used to make a hook only apply
  to examples with the given metadata.

  Scenario: Filter before(:each) hooks using arbitrary metadata
    Given a file named "filter_before_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:each, :foo => :bar) { puts "In hook" }
      end

      describe "group 1" do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end

      describe "group 2", :foo => :bar do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end
      """
    When I run "rspec filter_before_each_hooks_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      group 1
        example 1
      In hook
        example 2

      group 2
      In hook
        example 1
      In hook
        example 2
      """

  Scenario: Filter after(:each) hooks using arbitrary metadata
    Given a file named "filter_after_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.after(:each, :foo => :bar) { puts "In hook" }
      end

      describe "group 1" do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end

      describe "group 2", :foo => :bar do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end
      """
    When I run "rspec filter_after_each_hooks_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      group 1
        example 1
      In hook
        example 2

      group 2
      In hook
        example 1
      In hook
        example 2
      """

  Scenario: Filter around(:each) hooks using arbitrary metadata
    Given a file named "filter_around_each_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.around(:each, :foo => :bar) do |example|
          puts "Start hook"
          example.run
          puts "End hook"
        end
      end

      describe "group 1" do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end

      describe "group 2", :foo => :bar do
        it("example 1") { }
        it("example 2", :foo => :bar) { }
      end
      """
    When I run "rspec filter_around_each_hooks_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      group 1
        example 1
      Start hook
      End hook
        example 2

      group 2
      Start hook
      End hook
        example 1
      Start hook
      End hook
        example 2
      """

  Scenario: Filter before(:all) hooks using arbitrary metadata
    Given a file named "filter_before_all_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.before(:all, :foo => :bar) { puts "In hook" }
      end

      describe "group 1" do
        it("example 1") { }
        it("example 2") { }
      end

      describe "group 2", :foo => :bar do
        it("example 1") { }
        it("example 2") { }
      end
      """
    When I run "rspec filter_before_all_hooks_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      group 1
        example 1
        example 2

      group 2
      In hook
        example 1
        example 2
      """

  Scenario: Filter after(:all) hooks using arbitrary metadata
    Given a file named "filter_after_all_hooks_spec.rb" with:
      """
      RSpec.configure do |config|
        config.after(:all, :foo => :bar) { puts "In hook" }
      end

      describe "group 1" do
        it("example 1") { }
        it("example 2") { }
      end

      describe "group 2", :foo => :bar do
        it("example 1") { }
        it("example 2") { }
      end
      """
    When I run "rspec filter_after_all_hooks_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      group 1
        example 1
        example 2

      group 2
        example 1
        example 2
      In hook
      """
