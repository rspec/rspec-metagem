@wip
Feature: access running example

  In order to take advantage of services that are available
    in my examples when I'm writing matchers
  As an spec author
  I want to have an object that represents the running example

  Scenario: matcher defined via DSL
    Given a file named "example_spec.rb" with:
      """
      Rspec::Matchers.define :bar do
        match do |_|
          running_example.foo == "foo"
        end
      end

      describe "something" do
        def foo
          "foo"
        end

        it "does something" do
          "foo".should bar
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then I should see "1 example, 0 failures"
    
  Scenario: matcher defined via #new 
    Given a file named "example_spec.rb" with:
      """
      describe "something" do
        def bar
          Rspec::Matchers::Matcher.new :bar do
            match do |_|
              running_example.foo == "foo"
            end
          end
        end

        def foo
          "foo"
        end

        it "does something" do
          "foo".should bar
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then I should see "1 example, 0 failures"
