Feature: around hooks

  As a developer using RSpec
  I want to run the examples as part of a block given to a an arbitary function
  So that I can control the environment in which it is run

  Scenario: around blocks are run
    Given a file named "ensure_around_blocks_are_run.rb" with:
      """
      require "rspec/expectations"

      describe "around filters" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        it "gets run in order" do
          puts "in the example"
          1.should == 1
        end
      end
      """
    When I run "rspec ./ensure_around_blocks_are_run.rb"
    Then I should see matching:
      """
      around each before
      in the example
      around each after
      """


  Scenario: examples run by an around block should run in the configured context
    Given a file named "around_block_with_context.rb" with:
      """
      require "rspec/expectations"

      module IncludedInConfigureBlock
        def included_in_configure_block; end
      end

      Rspec.configure do |c|
        c.include IncludedInConfigureBlock
      end

      describe "around filters" do
        around(:each) do |example|
          example.run
        end

        it "maintain the correct configuration context" do
          respond_to?(:included_in_configure_block).should be_true
        end
      end
      """
    When I run "rspec ./around_block_with_context.rb"
    Then I should see "1 example, 0 failure"


  Scenario: implicitly pending examples should be detected as Not Yet Implemented
    Given a file named "around_block_with_implicit_pending_example.rb" with:
      """
      require "rspec/expectations"

      describe "implicit pending example" do
        around(:each) do |example|
          example.run
        end

        it "should be detected as Not Yet Implemented"
      end
      """
    When I run "rspec ./around_block_with_implicit_pending_example.rb"
    Then I should see "1 example, 0 failures, 1 pending"
    And I should see "implicit pending example should be detected as Not Yet Implemented (Not Yet Implemented)"


  Scenario: explicitly pending examples should be detected as pending
    Given a file named "around_block_with_explicit_pending_example.rb" with:
      """
      require "rspec/expectations"

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
    Then I should see "1 example, 0 failures, 1 pending"
    And I should see "explicit pending example should be detected as pending (No reason given)"


  Scenario: multiple around hooks in the same scope are all ran
    Given a file named "around_hooks_in_same_scope.rb" with:
    """
    require "rspec/expectations"

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
    Then I should see "1 example, 0 failure"
    And I should see matching:
    """
    first around hook before
    second around hook before
    in the example
    second around hook after
    first around hook after
    """


  Scenario: around hooks in outer scopes are ran
    Given a file named "around_hooks_in_outer_scope.rb" with:
    """
    require "rspec/expectations"

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
            1.should == 1
          end
        end
      end
    end
    """
    When I run "rspec ./around_hooks_in_outer_scope.rb"
    Then I should see "1 example, 0 failure"
    And I should see matching:
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
