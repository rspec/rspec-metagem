Feature: default_directory

  Use `config.default_directory` to set the spec directory that contains
  all of the examples. With this option, Executing `rspec` is equivalent to
  `rspec [default_directory]`. The default option is set to "spec".

  Scenario: the default default_directory is spec
    Given a file named "spec/example_spec.rb" with:
      """
      describe "an example" do
        it "passes" do
        end
      end
      """
    When I run `rspec -f doc`
    Then the output should contain "passes"
    
  Scenario: changing the default_directory
  
    Because this is a configuration that happens *before* spec files are
    loaded, we have to use a `.rspec` configuration file here. Normally, you
    would just do the following:
    
        RSpec.configure do |config|
          config.default_directory = :the_directory
        end
    
    Given a file named ".rspec" with:
      """
      --default_directory specs
      """
    Given a file named "specs/example_spec.rb" with:
      """      
      describe "an example" do
        it "passes" do
        end
      end
      """
    When I run `rspec -f doc`
    Then the output should contain "passes"