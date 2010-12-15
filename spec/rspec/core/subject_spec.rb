require 'spec_helper'

module RSpec::Core

  describe Subject do

    describe "implicit subject" do
      describe "with a class" do
        it "returns an instance of the class" do
          ExampleGroup.describe(Array).subject.call.should == []
        end
      end

      describe "with a Module" do
        it "returns the Module" do
          ExampleGroup.describe(Enumerable).subject.call.should == Enumerable
        end
      end

      describe "with a string" do
        it "return the string" do
          ExampleGroup.describe("Foo").subject.call.should == 'Foo'
        end
      end

      describe "with a number" do
        it "returns the number" do
          ExampleGroup.describe(15).subject.call.should == 15
        end
      end

    end

    describe "explicit subject" do
      [false, nil].each do |falsy_value|
        context "with a value of #{falsy_value.inspect}" do
          it "is evaluated once per example" do
            group = ExampleGroup.describe(Array)
            group.before do
              Object.should_receive(:this_question?).once.and_return(falsy_value)
            end
            group.subject do
              Object.this_question?
            end
            group.example do
              subject
              subject
            end
            group.run.should be_true, "expected subject block to be evaluated only once"
          end
        end
      end

      describe "defined in a top level group" do
        it "replaces the implicit subject in that group" do
          group = ExampleGroup.describe(Array)
          group.subject { [1,2,3] }
          group.subject.call.should == [1,2,3]
        end
      end

      describe "defined in a top level group" do
        let(:group) do
          ExampleGroup.describe do
            subject{ [4,5,6] }
          end
        end

        it "is available in a nested group (subclass)" do
          nested_group = group.describe("I'm nested!") { }
          nested_group.subject.call.should == [4,5,6]
        end

        it "is available in a doubly nested group (subclass)" do
          nested_group = group.describe("Nesting level 1") { }
          doubly_nested_group = nested_group.describe("Nesting level 2") { }
          doubly_nested_group.subject.call.should == [4,5,6]
        end
      end
    end

    context "using 'self' as an explicit subject" do
      it "delegates matcher to the ExampleGroup" do
        group = ExampleGroup.describe("group") do
          subject { self }
          def ok?; true; end

          it { should eq(self) }
          it { should be_ok }
        end

        group.run.should be_true
      end
    end

  end
end
