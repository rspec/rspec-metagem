module Rspec
  module Core
    describe RubyProject do
      describe "#determine_root" do
        context "no parent with spec directory" do
          it "returns the current directory" do
            RubyProject.stub(:find_first_parent_containing).and_return(nil)
            RubyProject.determine_root.should == '.'
          end
        end
        context "has parent with spec directory" do
          it "returns the directory containing the spec directory" do
            RubyProject.stub(:find_directory_parent).and_return('foodir')
            RubyProject.determine_root.should == 'foodir'
          end
        end
      end
    end
  end
end
