Feature: halt
  
  In an example, before hook, after hook, or around hook, you can
  halt the current example, group, or suite based on arbitrary
  criteria.

  @wip
  Scenario: halt group on failure
    Given a directory named "spec"
    And a file named "spec/example_spec.rb" with:
      """
      Rspec.configure do |c|
        c.after(:each) do
          running_example.halt(:group, :status => 'failed')
        end
      end
      describe "something" do
        it "fails" do
          fail 
        end

        it "does not run this example" do
        end
      end
      """
    When I run "rspec spec/example_spec.rb"
    Then the stdout should match "1 example, 1 failure"
