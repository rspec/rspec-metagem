Feature: around hooks

  As a developer using RSpec
  I want to run the examples as part of a block given to a an arbitary function
  So that I can control the environment in which it is run

  Scenario: around hooks defined in a group are run
    Given a file named "ensure_around_blocks_are_run.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec ./ensure_around_blocks_are_run.rb"
    Then the output should contain:
      """
      around each before
      in the example
      around each after
      """

  Scenario: argument passed to around hook can be treated as a proc
    Given a file named "treat_around_hook_arg_as_a_proc.rb" with:
      """
      describe "around filter" do
        def perform_around
          puts "around each before"
          yield
          puts "around each after"
        end

        around(:each) do |example|
          perform_around(&example)
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec ./treat_around_hook_arg_as_a_proc.rb"
    Then the output should contain:
      """
      around each before
      in the example
      around each after
      """

  Scenario: around hooks defined globally are run
    Given a file named "ensure_around_blocks_are_run.rb" with:
      """
      RSpec.configure do |c|
        c.around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end
      end

      describe "around filter" do
        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec ./ensure_around_blocks_are_run.rb"
    Then the output should contain:
      """
      around each before
      in the example
      around each after
      """

  Scenario: before/after(:each) hooks are wrapped by the around hook
    Given a file named "ensure_around_blocks_are_run.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        before(:each) do
          puts "before each"
        end

        after(:each) do
          puts "after each"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec ./ensure_around_blocks_are_run.rb"
    Then the output should contain:
      """
      around each before
      before each
      in the example
      after each
      around each after
      """

  Scenario: before/after(:all) hooks are NOT wrapped by the around hook
    Given a file named "ensure_around_blocks_are_run.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        before(:all) do
          puts "before all"
        end

        after(:all) do
          puts "after all"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec ./ensure_around_blocks_are_run.rb"
    Then the output should contain:
      """
      before all
      around each before
      in the example
      around each after
      .after all
      """

  Scenario: examples run by an around block should run in the configured context
    Given a file named "around_block_with_context.rb" with:
      """
      module IncludedInConfigureBlock
        def included_in_configure_block; true; end
      end

      Rspec.configure do |c|
        c.include IncludedInConfigureBlock
      end

      describe "around filter" do
        around(:each) do |example|
          example.run
        end

        it "runs the example in the correct context" do
          included_in_configure_block.should be_true
        end
      end
      """
    When I run "rspec ./around_block_with_context.rb"
    Then the output should contain "1 example, 0 failure"

  Scenario: implicitly pending examples should be detected as Not Yet Implemented
    Given a file named "around_block_with_implicit_pending_example.rb" with:
      """
      describe "implicit pending example" do
        around(:each) do |example|
          example.run
        end

        it "should be detected as Not Yet Implemented"
      end
      """
    When I run "rspec ./around_block_with_implicit_pending_example.rb"
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        implicit pending example should be detected as Not Yet Implemented
          # Not Yet Implemented
      """


  Scenario: explicitly pending examples should be detected as pending
    Given a file named "around_block_with_explicit_pending_example.rb" with:
      """
      describe "explicit pending example" do
        around(:each) do |example|
          example.run
        end

        it "should be detected as pending" do
          pending
        end
      end
      """
    When I run "rspec ./around_block_with_explicit_pending_example.rb"
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
        explicit pending example should be detected as pending
          # No reason given
      """

  Scenario: multiple around hooks in the same scope are all run
    Given a file named "around_hooks_in_same_scope.rb" with:
    """
    describe "if there are multiple around hooks in the same scope" do
      around(:each) do |example|
        puts "first around hook before"
        example.run
        puts "first around hook after"
      end

      around(:each) do |example|
        puts "second around hook before"
        example.run
        puts "second around hook after"
      end

      it "they should all be run" do
        puts "in the example"
        1.should == 1
      end
    end
    """
    When I run "rspec ./around_hooks_in_same_scope.rb"
    Then the output should contain "1 example, 0 failure"
    And the output should contain:
    """
    first around hook before
    second around hook before
    in the example
    second around hook after
    first around hook after
    """

  Scenario: around hooks in outer scopes are run
    Given a file named "around_hooks_in_outer_scope.rb" with:
    """
    describe "if there are around hooks in an outer scope" do
      around(:each) do |example|
        puts "first outermost around hook before"
        example.run
        puts "first outermost around hook after"
      end

      around(:each) do |example|
        puts "second outermost around hook before"
        example.run
        puts "second outermost around hook after"
      end

      describe "outer scope" do
        around(:each) do |example|
          puts "first outer around hook before"
          example.run
          puts "first outer around hook after"
        end

        around(:each) do |example|
          puts "second outer around hook before"
          example.run
          puts "second outer around hook after"
        end

        describe "inner scope" do
          around(:each) do |example|
            puts "first inner around hook before"
            example.run
            puts "first inner around hook after"
          end

          around(:each) do |example|
            puts "second inner around hook before"
            example.run
            puts "second inner around hook after"
          end

          it "they should all be run" do
            puts "in the example"
          end
        end
      end
    end
    """
    When I run "rspec ./around_hooks_in_outer_scope.rb"
    Then the output should contain "1 example, 0 failure"
    And the output should contain:
    """
    first outermost around hook before
    second outermost around hook before
    first outer around hook before
    second outer around hook before
    first inner around hook before
    second inner around hook before
    in the example
    second inner around hook after
    first inner around hook after
    second outer around hook after
    first outer around hook after
    second outermost around hook after
    first outermost around hook after
    """
