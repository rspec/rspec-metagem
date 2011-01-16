Feature: filters

  `before`/`after`/`around` hooks defined in the RSpec configuration block can
  be filtered using metadata.  Arbitrary metadata can be applied to an example
  or example group, and used to make a hook only apply to examples with the
  given metadata.

  Scenario: filter `before(:each)` hooks using arbitrary metadata
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
    Then the output should contain:
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

  Scenario: filter `after(:each)` hooks using arbitrary metadata
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
    Then the output should contain:
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

  Scenario: filter around(:each) hooks using arbitrary metadata
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
    Then the output should contain:
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

  Scenario: filter before(:all) hooks using arbitrary metadata
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

      describe "group 3" do
        describe "subgroup 1", :foo => :bar do
          it("example 1") { }
        end
      end
      """
    When I run "rspec filter_before_all_hooks_spec.rb --format documentation"
    Then the output should contain:
      """
      group 1
        example 1
        example 2

      group 2
      In hook
        example 1
        example 2

      group 3
        subgroup 1
      In hook
          example 1
      """

  Scenario: filter after(:all) hooks using arbitrary metadata
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

      describe "group 3" do
        describe "subgroup 1", :foo => :bar do
          it("example 1") { }
        end
      end
      """
    When I run "rspec filter_after_all_hooks_spec.rb --format documentation"
    Then the output should contain:
      """
      group 1
        example 1
        example 2

      group 2
        example 1
        example 2
      In hook

      group 3
        subgroup 1
          example 1
      In hook
      """
