require 'spec_helper'

module RSpec
  module Core
    RSpec.describe Metadata do

      describe '.relative_path' do
        let(:here) { File.expand_path(".") }
        it "transforms absolute paths to relative paths" do
          expect(Metadata.relative_path(here)).to eq "."
        end
        it "transforms absolute paths to relative paths anywhere in its argument" do
          expect(Metadata.relative_path("foo #{here} bar")).to eq "foo . bar"
        end
        it "returns nil if passed an unparseable file:line combo" do
          expect(Metadata.relative_path("-e:1")).to be_nil
        end
        # I have no idea what line = line.sub(/\A([^:]+:\d+)$/, '\\1') is supposed to do
        it "gracefully returns nil if run in a secure thread" do
          safely do
            value = Metadata.relative_path(".")
            # on some rubies, File.expand_path is not a security error, so accept "." as well
            expect([nil, "."]).to include(value)
          end
        end

      end

      context "when created" do
        Metadata::RESERVED_KEYS.each do |key|
          it "prohibits :#{key} as a hash key" do
            expect do
              RSpec.describe("group", key => {})
            end.to raise_error(/:#{key} is not allowed/)
          end
        end

        it "uses :caller if passed as part of the user metadata" do
          m = nil

          RSpec.describe('group', :caller => ['example_file:42']) do
            m = metadata
          end

          expect(m[:example_group][:location]).to eq("example_file:42")
        end
      end

      describe "#filter_applies?" do
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
            expect(group_metadata.filter_applies?(condition_key, group_condition)).to be_truthy
          end

          it "matches the example when the line_number is the grandparent example group line number" do
            expect(example_metadata.filter_applies?(condition_key, parent_group_condition)).to be_truthy
          end

          it "matches the example when the line_number is the parent example group line number" do
            expect(example_metadata.filter_applies?(condition_key, group_condition)).to be_truthy
          end

          it "matches the example when the line_number is the example line number" do
            expect(example_metadata.filter_applies?(condition_key, example_condition)).to be_truthy
          end

          it "matches when the line number is between this example and the next" do
            expect(example_metadata.filter_applies?(condition_key, between_examples_condition)).to be_truthy
          end

          it "does not match when the line number matches the next example" do
            expect(example_metadata.filter_applies?(condition_key, next_example_condition)).to be_falsey
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
            expect(example_metadata.filter_applies?(:locations, {"/path/to/other_spec.rb" => [3,5,7]})).to be_truthy
          end
        end

        it "matches a proc with no arguments that evaluates to true" do
          expect(example_metadata.filter_applies?(:if, lambda { true })).to be_truthy
        end

        it "matches a proc that evaluates to true" do
          expect(example_metadata.filter_applies?(:if, lambda { |v| v })).to be_truthy
        end

        it "does not match a proc that evaluates to false" do
          expect(example_metadata.filter_applies?(:if, lambda { |v| !v })).to be_falsey
        end

        it "matches a proc with an arity of 2" do
          example_metadata[:foo] = nil
          expect(example_metadata.filter_applies?(:foo, lambda { |v, m| m == example_metadata })).to be_truthy
        end

        it "raises an error when the proc has an incorrect arity" do
          expect {
            example_metadata.filter_applies?(:if, lambda { |a,b,c| true })
          }.to raise_error(ArgumentError)
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
            expect(metadata_with_array.filter_applies?(:tag, 'one')).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, :one)).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 'two')).to be_falsey
          end

          it "matches a string" do
            expect(metadata_with_array.filter_applies?(:tag, 'three')).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, :three)).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 'tree')).to be_falsey
          end

          it "matches an integer" do
            expect(metadata_with_array.filter_applies?(:tag, '2')).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 2)).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 3)).to be_falsey
          end

          it "matches a regexp" do
            expect(metadata_with_array.filter_applies?(:tag, 'four')).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 'fourtune')).to be_truthy
            expect(metadata_with_array.filter_applies?(:tag, 'fortune')).to be_falsey
          end

          it "matches a proc that evaluates to true" do
            expect(metadata_with_array.filter_applies?(:tag, lambda { |values| values.include? 'three' })).to be_truthy
          end

          it "does not match a proc that evaluates to false" do
            expect(metadata_with_array.filter_applies?(:tag, lambda { |values| values.include? 'nothing' })).to be_falsey
          end
        end
      end

      context "for an example" do
        let(:line_number) { __LINE__ + 3 }
        def metadata_for(*args)
          RSpec.describe("group description") do
            return example(*args).metadata
          end
        end
        alias example_metadata metadata_for

        RSpec::Matchers.define :have_value do |value|
          chain(:for) { |key| @key = key }

          match do |metadata|
            expect(metadata.fetch(@key)).to eq(value)
            expect(metadata[@key]).to eq(value)
          end
        end

        it "stores the description args" do
          expect(metadata_for "example description").to have_value(["example description"]).for(:description_args)
        end

        it "ignores nil description args" do
          expect(example_metadata).to have_value([]).for(:description_args)
        end

        it "stores the full_description (group description + example description)" do
          expect(metadata_for "example description").to have_value("group description example description").for(:full_description)
        end

        it "creates an empty execution result" do
          expect(example_metadata).to have_value({}).for(:execution_result)
        end

        it "extracts file path from caller" do
          expect(example_metadata).to have_value(relative_path(__FILE__)).for(:file_path)
        end

        it "extracts line number from caller" do
          expect(example_metadata).to have_value(line_number).for(:line_number)
        end

        it "extracts location from caller" do
          expect(example_metadata).to have_value("#{relative_path(__FILE__)}:#{line_number}").for(:location)
        end

        it "uses :caller if passed as an option" do
          example_metadata = metadata_for('example description', :caller => ['example_file:42'])
          expect(example_metadata).to have_value("example_file:42").for(:location)
        end

        it "merges arbitrary options" do
          expect(metadata_for("desc", :arbitrary => :options)).to have_value(:options).for(:arbitrary)
        end

        it "points :example_group to the same hash object" do
          a = b = nil

          RSpec.describe "group" do
            a = example("foo").metadata[:example_group]
            b = example("bar").metadata[:example_group]
          end

          a[:description] = "new description"
          expect(b[:description]).to eq("new description")
        end
      end

      [:described_class, :describes].each do |key|
        describe key do
          extract_key_from = lambda do |group|
            group.metadata[:example_group][key]
          end

          context "in an outer group" do
            define_method :value_for do |arg|
              extract_key_from[RSpec.describe(arg)]
            end

            context "with a String" do
              it "returns nil" do
                expect(value_for "group").to be_nil
              end
            end

            context "with a Symbol" do
              it "returns nil" do
                expect(value_for :group).to be_nil
              end
            end

            context "with a class" do
              it "returns the class" do
                expect(value_for String).to be(String)
              end
            end
          end

          context "in a nested group" do
            it "inherits the parent group's described class" do
              value = nil

              RSpec.describe(Hash) do
                describe "sub context" do
                  value = extract_key_from[self]
                end
              end

              expect(value).to be(Hash)
            end

            it "sets the described class when passing a class" do
              value = nil

              RSpec.describe(String) do
                describe Array do
                  value = extract_key_from[self]
                end
              end

              expect(value).to be(Array)
            end

            it "can override a parent group's described class using metdata" do
              parent_value = child_value = grandchild_value = nil

              RSpec.describe(String) do
                parent_value = extract_key_from[self]

                describe "sub context" do
                  metadata[:example_group][key] = Hash
                  child_value = extract_key_from[self]

                  describe "sub context" do
                    grandchild_value = extract_key_from[self]
                  end
                end
              end

              expect(grandchild_value).to be(Hash)
              expect(child_value).to be(Hash)
              expect(parent_value).to be(String)
            end
          end
        end
      end

      describe ":description" do
        context "on a example" do
          it "just has the example description" do
            value = nil

            RSpec.describe "group" do
              value = example("example").metadata[:description]
            end

            expect(value).to eq("example")
          end
        end

        context "on a group" do
          def group_value_for(*args)
            value = nil

            RSpec.describe(*args) do
              value = metadata[:example_group][:description]
            end

            value
          end

          context "with a string" do
            it "provides the submitted description" do
              expect(group_value_for "group").to eq("group")
            end
          end

          context "with a non-string" do
            it "provides the string form of the submitted object" do
              expect(group_value_for Hash).to eq("Hash")
            end
          end

          context "with a non-string and a string" do
            it "concats the args" do
              expect(group_value_for Object, 'group').to eq("Object group")
            end
          end

          context "with empty args" do
            it "returns empty string for [:example_group][:description]" do
              expect(group_value_for()).to eq("")
            end
          end
        end
      end

      describe ":full_description" do
        context "on an example" do
          it "concats example group name and description" do
            value = nil

            RSpec.describe "group" do
              value = example("example").metadata[:full_description]
            end

            expect(value).to eq("group example")
          end
        end

        it "concats nested example group descriptions" do
          group_value = example_value = nil

          RSpec.describe "parent" do
            describe "child" do
              group_value = metadata[:example_group][:full_description]
              example_value = example("example").metadata[:full_description]
            end
          end

          expect(group_value).to eq("parent child")
          expect(example_value).to eq("parent child example")
        end

        it "concats nested example group descriptions three deep" do
          grandparent_value = parent_value = child_value = example_value = nil

          RSpec.describe "grandparent" do
            grandparent_value = metadata[:example_group][:full_description]
            describe "parent" do
              parent_value = metadata[:example_group][:full_description]
              describe "child" do
                child_value = metadata[:example_group][:full_description]
                example_value = example("example").metadata[:full_description]
              end
            end
          end

          expect(grandparent_value).to eq("grandparent")
          expect(parent_value).to eq("grandparent parent")
          expect(child_value).to eq("grandparent parent child")
          expect(example_value).to eq("grandparent parent child example")
        end

        %w[# . ::].each do |char|
          context "with a 2nd arg starting with #{char}" do
            it "removes the space" do
              value = nil

              RSpec.describe Array, "#{char}method" do
                value = metadata[:example_group][:full_description]
              end

              expect(value).to eq("Array#{char}method")
            end
          end

          context "with a description starting with #{char} nested under a module" do
            it "removes the space" do
              value = nil

              RSpec.describe Object do
                describe "#{char}method" do
                  value = metadata[:example_group][:full_description]
                end
              end

              expect(value).to eq("Object#{char}method")
            end
          end

          context "with a description starting with #{char} nested under a context string" do
            it "does not remove the space" do
              value = nil

              RSpec.describe(Array) do
                context "with 2 items" do
                  describe "#{char}method" do
                    value = metadata[:example_group][:full_description]
                  end
                end
              end

              expect(value).to eq("Array with 2 items #{char}method")
            end
          end
        end
      end

      describe ":file_path" do
        it "finds the first non-rspec lib file in the caller array" do
          value = nil

          RSpec.describe(:caller => ["./lib/rspec/core/foo.rb", "#{__FILE__}:#{__LINE__}"]) do
            value = metadata[:example_group][:file_path]
          end

          expect(value).to eq(relative_path(__FILE__))
        end
      end

      describe ":line_number" do
        def value_for(*args)
          value = nil

          @describe_line = __LINE__ + 1
          RSpec.describe(*args) do
            value = metadata[:example_group][:line_number]
          end

          value
        end

        it "finds the line number with the first non-rspec lib file in the backtrace" do
          expect(value_for()).to eq(@describe_line)
        end

        it "finds the line number with the first spec file with drive letter" do
          expect(value_for(:caller => [ "C:/path/to/file_spec.rb:#{__LINE__}" ])).to eq(__LINE__)
        end

        it "uses the number after the first : for ruby 1.9" do
          expect(value_for(:caller => [ "#{__FILE__}:#{__LINE__}:999" ])).to eq(__LINE__)
        end
      end

      describe "child example group" do
        it "nests the parent's example group metadata" do
          child = parent = nil

          RSpec.describe Object, "parent" do
            parent = metadata
            describe { child = metadata }
          end

          expect(child[:example_group][:example_group]).to eq(parent[:example_group])
        end
      end
    end
  end
end
