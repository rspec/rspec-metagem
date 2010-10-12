require 'spec_helper'

RSpec::Matchers.define :be_pending_with do |message|
  match do |example|
    example.metadata[:pending] && example.metadata[:execution_result][:pending_message] == message
  end

  failure_message_for_should do |example|
    "expected example to pending with #{message.inspect}, got #{example.metadata[:execution_result][:pending_message].inspect}"
  end
end

describe "an example" do
  context "with no block" do
    it "is listed as pending with 'Not Yet Implemented'" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "has no block"
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('Not Yet Implemented')
    end
  end

  context "with no args" do
    it "is listed as pending with 'No reason given'" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('No reason given')
    end
  end

  context "with no docstring" do
    context "declared with the pending method" do
      it "does not have an auto-generated description" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            (3+4).should == 7
          end
          pending do
            "string".reverse.should == "gnirts"
          end
        end
        example = group.examples.last
        example.run(group.new, stub.as_null_object)
        example.description.should be_empty
      end
    end
    context "after another example with some assertion" do
      it "does not show any message" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            (3+4).should == 7
          end
          specify do
            pending
          end
        end
        example = group.examples.last
        example.run(group.new, stub.as_null_object)
        example.description.should be_empty
      end
    end
  end

  context "with a message" do
    it "is listed as pending with the supplied message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending("just because")
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('just because')
    end
  end

  context "with a block" do
    context "that fails" do
      it "is listed as pending with the supplied message" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "does something" do
            pending("just because") do
              3.should == 4
            end
          end
        end
        example = group.examples.first
        example.run(group.new, stub.as_null_object)
        example.should be_pending_with('just because')
      end
    end

    context "that passes" do
      it "raises a PendingExampleFixedError" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "does something" do
            pending("just because") do
              3.should == 3
            end
          end
        end
        example = group.examples.first
        example.run(group.new, stub.as_null_object)
        example.metadata[:pending].should be_false
        example.metadata[:execution_result][:status].should == 'failed'
        example.metadata[:execution_result][:exception_encountered].should be_a(RSpec::Core::PendingExampleFixedError)
      end
    end
  end

end
