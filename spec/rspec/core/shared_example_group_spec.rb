require 'rspec/support/spec/in_sub_process'

module RandomTopLevelModule
  def self.setup!
    RSpec.shared_examples_for("top level in module") {}
  end
end

module RSpec
  module Core
    RSpec.describe SharedExampleGroup do
      include RSpec::Support::InSubProcess
      let(:registry) { RSpec.world.shared_example_group_registry }

      ExampleModule = Module.new
      ExampleClass  = Class.new

      it 'does not add a bunch of private methods to Module' do
        seg_methods = RSpec::Core::SharedExampleGroup.private_instance_methods
        expect(Module.private_methods & seg_methods).to eq([])
      end

      before do
        # this is a work around as SharedExampleGroup is not world safe
        RandomTopLevelModule.setup!
      end

      RSpec::Matchers.define :have_example_descriptions do |*descriptions|
        match do |group|
          group.examples.map(&:description) == descriptions
        end

        failure_message do |group|
          actual = group.examples.map(&:description)
          "expected #{group.name} to have descriptions: #{descriptions.inspect} but had #{actual.inspect}"
        end
      end

      %w[shared_examples shared_examples_for shared_context].each do |shared_method_name|
        describe shared_method_name do
          let(:group) { RSpec.describe('example group') }

          define_method :define_shared_group do |*args, &block|
            group.send(shared_method_name, *args, &block)
          end

          it "is exposed to the global namespace when expose_dsl_globally is enabled" do
            in_sub_process do
              RSpec.configuration.expose_dsl_globally = true
              expect(Kernel).to respond_to(shared_method_name)
            end
          end

          it "is not exposed to the global namespace when monkey patching is disabled" do
            expect(Kernel).to_not respond_to(shared_method_name)
          end

          it "displays a warning when adding a second shared example group with the same name" do
            group.send(shared_method_name, 'some shared group') {}
            original_declaration = [__FILE__, __LINE__ - 1].join(':')

            warning = nil
            allow(::Kernel).to receive(:warn) { |msg| warning = msg }

            group.send(shared_method_name, 'some shared group') {}
            second_declaration = [__FILE__, __LINE__ - 1].join(':')
            expect(warning).to include('some shared group', original_declaration, second_declaration)
            expect(warning).to_not include 'Called from'
          end

          it 'works with top level defined examples in modules' do
            expect(RSpec::configuration.reporter).to_not receive(:deprecation)
            RSpec.describe('example group') { include_context 'top level in module' }
          end

          it 'generates a named (rather than anonymous) module' do
            define_shared_group("shared behaviors", :include_it) { }
            group = RSpec.describe("Group", :include_it) { }

            anonymous_module_regex = /#<Module:0x[0-9a-f]+>/
            expect(Module.new.inspect).to match(anonymous_module_regex)

            include_a_named_rather_than_anonymous_module = (
              include(a_string_including(
                "#<RSpec::Core::SharedExampleGroupModule", "shared behaviors"
              )).and exclude(a_string_matching(anonymous_module_regex))
            )

            expect(group.ancestors.map(&:inspect)).to include_a_named_rather_than_anonymous_module
            expect(group.ancestors.map(&:to_s)).to include_a_named_rather_than_anonymous_module
          end

          ["name", :name, ExampleModule, ExampleClass].each do |object|
            type = object.class.name.downcase
            context "given a #{type}" do
              it "captures the given #{type} and block in the collection of shared example groups" do
                implementation = lambda { }
                define_shared_group(object, &implementation)
                expect(registry.find([group], object)).to eq implementation
              end
            end
          end

          context "given a hash" do
            it "includes itself in matching example groups" do
              implementation = Proc.new { def self.bar; 'bar'; end }
              define_shared_group(:foo => :bar, &implementation)

              matching_group = RSpec.describe "Group", :foo => :bar
              non_matching_group = RSpec.describe "Group"

              expect(matching_group.bar).to eq("bar")
              expect(non_matching_group).not_to respond_to(:bar)
            end
          end

          context "given a string and a hash" do
            it "captures the given string and block in the World's collection of shared example groups" do
              implementation = lambda { }
              define_shared_group("name", :foo => :bar, &implementation)
              expect(registry.find([group], "name")).to eq implementation
            end

            it "delegates include on configuration" do
              implementation = Proc.new { def self.bar; 'bar'; end }
              define_shared_group("name", :foo => :bar, &implementation)

              matching_group = RSpec.describe "Group", :foo => :bar
              non_matching_group = RSpec.describe "Group"

              expect(matching_group.bar).to eq("bar")
              expect(non_matching_group).not_to respond_to(:bar)
            end
          end

          context "when called at the top level" do
            before do
              RSpec.__send__(shared_method_name, "shared context") do
                example "shared spec"
              end
            end

            it 'is available for inclusion from a top level group' do
              group = RSpec.describe "group" do
                include_examples "shared context"
              end

              expect(group).to have_example_descriptions("shared spec")
            end

            it 'is available for inclusion from a nested example group' do
              group = nil

              RSpec.describe "parent" do
                context "child" do
                  group = context("grand child") { include_examples "shared context" }
                end
              end

              expect(group).to have_example_descriptions("shared spec")
            end

            it 'is trumped by a shared group with the same name that is defined in the including context' do
              group = RSpec.describe "parent" do
                __send__ shared_method_name, "shared context" do
                  example "a different spec"
                end

                include_examples "shared context"
              end

              expect(group).to have_example_descriptions("a different spec")
            end

            it 'is trumped by a shared group with the same name that is defined in a parent group' do
              group = nil

              RSpec.describe "parent" do
                __send__ shared_method_name, "shared context" do
                  example "a different spec"
                end

                group = context("nested") { include_examples "shared context" }
              end

              expect(group).to have_example_descriptions("a different spec")
            end
          end

          context "when called from within an example group" do
            define_method :in_group_with_shared_group_def do |&block|
              RSpec.describe "an example group" do
                __send__ shared_method_name, "shared context" do
                  example "shared spec"
                end

                module_exec(&block)
              end
            end

            it 'is available for inclusion within that group' do
              group = in_group_with_shared_group_def do
                include_examples "shared context"
              end

              expect(group).to have_example_descriptions("shared spec")
            end

            it 'is available for inclusion in a child group' do
              group = nil

              in_group_with_shared_group_def do
                group = context("nested") { include_examples "shared context" }
              end

              expect(group).to have_example_descriptions("shared spec")
            end

            it 'is not available for inclusion in a different top level group' do
              in_group_with_shared_group_def { }

              expect {
                RSpec.describe "another top level group" do
                  include_examples "shared context"
                end
              }.to raise_error(/Could not find/)
            end

            it 'is not available for inclusion in a nested group of a different top level group' do
              in_group_with_shared_group_def { }

              expect {
                RSpec.describe "another top level group" do
                  context("nested") { include_examples "shared context" }
                end
              }.to raise_error(/Could not find/)
            end

            it 'trumps a shared group with the same name defined at the top level' do
              RSpec.__send__(shared_method_name, "shared context") do
                example "a different spec"
              end

              group = in_group_with_shared_group_def do
                include_examples "shared context"
              end

              expect(group).to have_example_descriptions("shared spec")
            end

            it 'is trumped by a shared group with the same name that is defined in the including context' do
              group = nil

              in_group_with_shared_group_def do
                group = context "child" do
                  __send__ shared_method_name, "shared context" do
                    example "a different spec"
                  end

                  include_examples "shared context"
                end
              end

              expect(group).to have_example_descriptions("a different spec")
            end

            it 'is trumped by a shared group with the same name that is defined in nearer parent group' do
              group = nil

              in_group_with_shared_group_def do
                context "child" do
                  __send__ shared_method_name, "shared context" do
                    example "a different spec"
                  end

                  group = context("grandchild") { include_examples "shared context" }
                end
              end

              expect(group).to have_example_descriptions("a different spec")
            end
          end
        end
      end
    end
  end
end

