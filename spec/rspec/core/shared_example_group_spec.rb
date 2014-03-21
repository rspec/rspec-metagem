require 'spec_helper'
require 'rspec/support/spec/in_sub_process'

module RandomTopLevelModule
  def self.setup!
    RSpec.shared_examples_for("top level in module") {}
  end
end

module RSpec
  module Core
    module SharedExampleGroup
      RSpec.describe Collection do

        # this represents:
        #
        # shared_examples "top level group"
        #
        # context do
        #   shared_examples "nested level one"
        # end
        #
        # context do
        #   shared_examples "nested level two"
        # end
        #
        let(:examples) do
          Hash.new { |hash,k| hash[k] = Hash.new }.tap do |hash|
            hash["main"]     = { "top level group"  => example_1 }
            hash["nested 1"] = { "nested level one" => example_2 }
            hash["nested 2"] = { "nested level two" => example_3 }
          end
        end

        let(:example_1) { double("example 1") }
        let(:example_2) { double("example 2") }
        let(:example_3) { double("example 3") }

        context 'setup with one source, which is the top level' do

          let(:collection) { Collection.new ['main'], examples }

          it 'fetches examples from the top level' do
            expect(collection['top level group']).to eq example_1
          end

          it 'wont fetches examples across the nested context' do
            expect(collection['nested level two']).to eq nil
          end
        end

        context 'setup with multiple sources' do

          let(:collection) { Collection.new ['main','nested 1'], examples }

          it 'fetches examples from the context' do
            expect(collection['nested level one']).to eq example_2
          end

          it 'fetches examples from main' do
            expect(collection['top level group']).to eq example_1
          end

          it 'wont fetch examples across the nested context' do
            expect(collection['nested level two']).to eq nil
          end
        end
      end
    end

    RSpec.describe SharedExampleGroup do
      include RSpec::Support::InSubProcess

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

      %w[share_examples_for shared_examples_for shared_examples shared_context].each do |shared_method_name|
        describe shared_method_name do
          let(:group) { ExampleGroup.describe('example group') }

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
            ExampleGroup.describe('example group') { include_context 'top level in module' }
          end

          ["name", :name, ExampleModule, ExampleClass].each do |object|
            type = object.class.name.downcase
            context "given a #{type}" do
              it "captures the given #{type} and block in the collection of shared example groups" do
                implementation = lambda {}
                define_shared_group(object, &implementation)
                expect(RSpec.world.shared_example_group_registry.shared_example_groups[group][object]).to eq implementation
              end
            end
          end

          context "given a hash" do
            it "delegates include on configuration" do
              implementation = Proc.new { def bar; 'bar'; end }
              define_shared_group(:foo => :bar, &implementation)
              a = RSpec.configuration.include_or_extend_modules.first
              expect(a[0]).to eq(:include)
              expect(Class.new.send(:include, a[1]).new.bar).to eq('bar')
              expect(a[2]).to eq(:foo => :bar)
            end
          end

          context "given a string and a hash" do
            it "captures the given string and block in the World's collection of shared example groups" do
              implementation = lambda {}
              define_shared_group("name", :foo => :bar, &implementation)
              expect(RSpec.world.shared_example_group_registry.shared_example_groups[group]["name"]).to eq implementation
            end

            it "delegates include on configuration" do
              implementation = Proc.new { def bar; 'bar'; end }
              define_shared_group("name", :foo => :bar, &implementation)
              a = RSpec.configuration.include_or_extend_modules.first
              expect(a[0]).to eq(:include)
              expect(Class.new.send(:include, a[1]).new.bar).to eq('bar')
              expect(a[2]).to eq(:foo => :bar)
            end
          end
        end
      end
    end
  end
end

