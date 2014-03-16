require 'spec_helper'

RSpec.describe "an example" do
  context "declared pending with metadata" do
    it "uses the value assigned to :pending as the message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        example "example", :pending => 'just because' do
          fail
        end
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_pending_with('just because')
    end

    it "sets the message to 'No reason given' if :pending => true" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        example "example", :pending => true do
          fail
        end
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_pending_with('No reason given')
    end

    it "passes if a mock expectation is not satisifed" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        example "example", :pending => "because" do
          expect(RSpec).to receive(:a_message_in_a_bottle)
        end
      end

      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_pending_with('because')
      expect(example.execution_result.status).to eq('pending')
    end

    it "does not mutate the :pending attribute of the user metadata when handling mock expectation errors" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        example "example", :pending => "because" do
          expect(RSpec).to receive(:a_message_in_a_bottle)
        end
      end

      group.run
      example = group.examples.first
      expect(example.metadata[:pending]).to be_truthy
    end
  end

  context "with no block" do
    it "is listed as pending with 'Not yet implemented'" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "has no block"
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_skipped_with('Not yet implemented')
    end
  end

  context "with no args" do
    it "is listed as pending with the default message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
          fail
        end
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_pending_with(RSpec::Core::Pending::NO_REASON_GIVEN)
    end

    it "fails when the rest of the example passes" do
      called = false
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
          called = true
        end
      end

      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(called).to eq(true)
      result = example.execution_result
      expect(result.pending_fixed).to eq(true)
      expect(result.status).to eq("failed")
    end

    it "does not mutate the :pending attribute of the user metadata when the rest of the example passes" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
        end
      end

      group.run
      example = group.examples.first
      expect(example.metadata).to include(:pending => true)
    end
  end

  context "with no docstring" do
    context "declared with the pending method" do
      it "has an auto-generated description" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            expect((3+4)).to eq(7)
          end
          pending do
            expect("string".reverse).to eq("gnirts")
          end
        end
        example = group.examples.last
        example.run(group.new, double.as_null_object)
        expect(example.description).to eq('should eq "gnirts"')
      end
    end

    context "after another example with some assertion" do
      it "does not show any message" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            expect((3+4)).to eq(7)
          end
          specify do
            pending
          end
        end
        example = group.examples.last
        example.run(group.new, double.as_null_object)
        expect(example.description).to match(/example at/)
      end
    end
  end

  context "with a message" do
    it "is listed as pending with the supplied message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending("just because")
          fail
        end
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_pending_with('just because')
    end
  end
end
