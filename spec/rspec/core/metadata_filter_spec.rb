require 'spec_helper'

module RSpec
  module Core
    RSpec.describe MetadataFilter do
      describe ".filter_applies?" do
        attr_accessor :parent_group_metadata, :group_metadata, :example_metadata

        def create_metadatas
          container = self

          RSpec.describe "parent group", :caller => ["foo_spec.rb:#{__LINE__}"] do; container.parent_group_metadata = metadata
            describe "group", :caller => ["foo_spec.rb:#{__LINE__}"] do; container.group_metadata = metadata
              container.example_metadata = it("example", :caller => ["foo_spec.rb:#{__LINE__}"], :if => true).metadata
            end
          end
        end

        let(:world) { World.new }

        before do
          allow(RSpec).to receive(:world) { world }
          create_metadatas
        end

        def filter_applies?(key, value, metadata)
          MetadataFilter.filter_applies?(key, value, metadata)
        end

        shared_examples_for "matching by line number" do
          let(:preceeding_declaration_lines) {{
            parent_group_metadata[:example_group][:line_number] => parent_group_metadata[:example_group][:line_number],
            group_metadata[:example_group][:line_number] => group_metadata[:example_group][:line_number],
            example_metadata[:line_number] => example_metadata[:line_number],
            (example_metadata[:line_number] + 1) => example_metadata[:line_number],
            (example_metadata[:line_number] + 2) => example_metadata[:line_number] + 2,
          }}
          before do
            expect(world).to receive(:preceding_declaration_line).at_least(:once) do |v|
              preceeding_declaration_lines[v]
            end
          end

          it "matches the group when the line_number is the example group line number" do
            # this call doesn't really make sense since filter_applies? is only called
            # for example metadata not group metadata
            expect(filter_applies?(condition_key, group_condition, group_metadata)).to be_truthy
          end

          it "matches the example when the line_number is the grandparent example group line number" do
            expect(filter_applies?(condition_key, parent_group_condition, example_metadata)).to be_truthy
          end

          it "matches the example when the line_number is the parent example group line number" do
            expect(filter_applies?(condition_key, group_condition, example_metadata)).to be_truthy
          end

          it "matches the example when the line_number is the example line number" do
            expect(filter_applies?(condition_key, example_condition, example_metadata)).to be_truthy
          end

          it "matches when the line number is between this example and the next" do
            expect(filter_applies?(condition_key, between_examples_condition, example_metadata)).to be_truthy
          end

          it "does not match when the line number matches the next example" do
            expect(filter_applies?(condition_key, next_example_condition, example_metadata)).to be_falsey
          end
        end

        context "with a single line number" do
          let(:condition_key){ :line_numbers }
          let(:parent_group_condition) { [parent_group_metadata[:example_group][:line_number]] }
          let(:group_condition) { [group_metadata[:example_group][:line_number]] }
          let(:example_condition) { [example_metadata[:line_number]] }
          let(:between_examples_condition) { [group_metadata[:example_group][:line_number] + 1] }
          let(:next_example_condition) { [example_metadata[:line_number] + 2] }

          it_has_behavior "matching by line number"
        end

        context "with multiple line numbers" do
          let(:condition_key){ :line_numbers }
          let(:parent_group_condition) { [-1, parent_group_metadata[:example_group][:line_number]] }
          let(:group_condition) { [-1, group_metadata[:example_group][:line_number]] }
          let(:example_condition) { [-1, example_metadata[:line_number]] }
          let(:between_examples_condition) { [-1, group_metadata[:example_group][:line_number] + 1] }
          let(:next_example_condition) { [-1, example_metadata[:line_number] + 2] }

          it_has_behavior "matching by line number"
        end

        context "with locations" do
          let(:condition_key){ :locations }
          let(:parent_group_condition) do
            {File.expand_path(parent_group_metadata[:example_group][:file_path]) => [parent_group_metadata[:example_group][:line_number]]}
          end
          let(:group_condition) do
            {File.expand_path(group_metadata[:example_group][:file_path]) => [group_metadata[:example_group][:line_number]]}
          end
          let(:example_condition) do
            {File.expand_path(example_metadata[:file_path]) => [example_metadata[:line_number]]}
          end
          let(:between_examples_condition) do
            {File.expand_path(group_metadata[:example_group][:file_path]) => [group_metadata[:example_group][:line_number] + 1]}
          end
          let(:next_example_condition) do
            {File.expand_path(example_metadata[:file_path]) => [example_metadata[:line_number] + 2]}
          end

          it_has_behavior "matching by line number"

          it "ignores location filters for other files" do
            expect(filter_applies?(:locations, {"/path/to/other_spec.rb" => [3,5,7]}, example_metadata)).to be_truthy
          end
        end

        it "matches a proc with no arguments that evaluates to true" do
          expect(filter_applies?(:if, lambda { true }, example_metadata)).to be_truthy
        end

        it "matches a proc that evaluates to true" do
          expect(filter_applies?(:if, lambda { |v| v }, example_metadata)).to be_truthy
        end

        it "does not match a proc that evaluates to false" do
          expect(filter_applies?(:if, lambda { |v| !v }, example_metadata)).to be_falsey
        end

        it "matches a proc with an arity of 2" do
          example_metadata[:foo] = nil
          expect(filter_applies?(:foo, lambda { |v, m| m == example_metadata }, example_metadata)).to be_truthy
        end

        it "raises an error when the proc has an incorrect arity" do
          expect {
            filter_applies?(:if, lambda { |a,b,c| true }, example_metadata)
          }.to raise_error(ArgumentError)
        end

        context "with a nested hash" do
          it 'matches when the nested entry matches' do
            metadata = { :foo => { :bar => "words" } }
            expect(filter_applies?(:foo, { :bar => /wor/ }, metadata)).to be_truthy
          end

          it 'does not match when the nested entry does not match' do
            metadata = { :foo => { :bar => "words" } }
            expect(filter_applies?(:foo, { :bar => /sword/ }, metadata)).to be_falsey
          end

          it 'does not match when the metadata lacks the key' do
            expect(filter_applies?(:foo, { :bar => /sword/ }, {})).to be_falsey
          end

          it 'does not match when the metadata does not have a hash entry for the key' do
            metadata = { :foo => "words" }
            expect(filter_applies?(:foo, { :bar => /word/ }, metadata)).to be_falsey
          end
        end

        context "with an Array" do
          let(:metadata_with_array) do
            meta = nil
            RSpec.describe("group") do
              meta = example('example_with_array', :tag => [:one, 2, 'three', /four/]).metadata
            end
            meta
          end

          it "matches a symbol" do
            expect(filter_applies?(:tag, 'one', metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, :one, metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 'two', metadata_with_array)).to be_falsey
          end

          it "matches a string" do
            expect(filter_applies?(:tag, 'three', metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, :three, metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 'tree', metadata_with_array)).to be_falsey
          end

          it "matches an integer" do
            expect(filter_applies?(:tag, '2', metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 2, metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 3, metadata_with_array)).to be_falsey
          end

          it "matches a regexp" do
            expect(filter_applies?(:tag, 'four', metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 'fourtune', metadata_with_array)).to be_truthy
            expect(filter_applies?(:tag, 'fortune', metadata_with_array)).to be_falsey
          end

          it "matches a proc that evaluates to true" do
            expect(filter_applies?(:tag, lambda { |values| values.include? 'three' }, metadata_with_array)).to be_truthy
          end

          it "does not match a proc that evaluates to false" do
            expect(filter_applies?(:tag, lambda { |values| values.include? 'nothing' }, metadata_with_array)).to be_falsey
          end
        end
      end
    end
  end
end
