Feature: default_path

  Use `config.default_path` to set the spec directory that contains
  all of the examples. With this option, executing `rspec` is equivalent to
  `rspec [default_path]`. The default option is set to "spec".

  Scenario: the default default_path is spec
    Given a file named "spec/example_spec.rb" with:
      """
      describe "an example" do
        it "passes" do
        end
      end
      """
    When I run `rspec -f doc`
    Then the output should contain "passes"
    
  Scenario: changing the default_path
  
    Because this is a configuration that happens *before* spec files are
    loaded, we have to use a `.rspec` configuration file here. Normally, you
    would just do the following:
    
        RSpec.configure do |config|
          config.default_path = :the_directory
        end
    
    Given a file named ".rspec" with:
      """
      --default_path specs
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