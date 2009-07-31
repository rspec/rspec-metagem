require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Mocha Regression involving double reporting of errors" do
  
  it "should not double report mocha errors" do
    # The below example should have one error, not two
    # I'm also not sure how to test this regression without having the failure counting by 
    # the running Rspec::Core instance
    formatter = Rspec::Core::Formatters::BaseFormatter.new

    use_formatter(formatter) do

      isolate_behaviour do
        desc = Rspec::Core::ExampleGroup.describe("my favorite pony") do
          example("showing a double fail") do
            foo = "string"
            foo.expects(:something)
          end
        end      
        desc.examples_to_run.replace(desc.examples)
        desc.run(formatter)
      end

    end

    formatter.examples.size.should == 1  
  end

end
