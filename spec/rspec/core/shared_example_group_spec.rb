require 'spec_helper'

module RSpec::Core
  describe SharedExampleGroup do

    ExampleModule = Module.new
    ExampleClass = Class.new

    it 'does not add a bunch of private methods to Module' do
      seg_methods = RSpec::Core::SharedExampleGroup.private_instance_methods
      expect(Module.private_methods & seg_methods).to eq([])
    end

    %w[share_examples_for shared_examples_for shared_examples shared_context].each do |shared_method_name|
      describe shared_method_name do
        it "is exposed to the global namespace" do
          Kernel.should respond_to(shared_method_name)
        end

        it "displays a warning when adding a second shared example group with the same name" do
          group = ExampleGroup.describe('example group')
          group.send(shared_method_name, 'some shared group') {}
          original_declaration = [__FILE__, __LINE__ - 1].join(':')

          warning = nil
          Kernel.stub(:warn) { |msg| warning = msg }

          group.send(shared_method_name, 'some shared group') {}
          second_declaration = [__FILE__, __LINE__ - 1].join(':')
          warning.should include('some shared group', original_declaration, second_declaration)
        end

        ["name", :name, ExampleModule, ExampleClass].each do |object|
          type = object.class.name.downcase
          context "given a #{type}" do
            it "captures the given #{type} and block in the World's collection of shared example groups" do
              implementation = lambda {}
              RSpec.world.shared_example_groups.should_receive(:[]=).with(object, implementation)
              send(shared_method_name, object, &implementation)
            end
          end
        end

        context "given a hash" do
          it "delegates extend on configuration" do
            implementation = Proc.new { def bar; 'bar'; end }
            send(shared_method_name, :foo => :bar, &implementation)
            a = RSpec.configuration.include_or_extend_modules.first
            a[0].should eq(:extend)
            Class.new.extend(a[1]).new.bar.should eq('bar')
            a[2].should eq(:foo => :bar)
          end
        end

        context "given a string and a hash" do
          it "captures the given string and block in the World's collection of shared example groups" do
            implementation = lambda {}
            RSpec.world.shared_example_groups.should_receive(:[]=).with("name", implementation)
            send(shared_method_name, "name", :foo => :bar, &implementation)
          end

          it "delegates extend on configuration" do
            implementation = Proc.new { def bar; 'bar'; end }
            send(shared_method_name, "name", :foo => :bar, &implementation)
            a = RSpec.configuration.include_or_extend_modules.first
            a[0].should eq(:extend)
            Class.new.extend(a[1]).new.bar.should eq('bar')
            a[2].should eq(:foo => :bar)
          end
        end
      end
    end

    describe "#share_as" do
      before { RSpec.stub(:warn) }

      it "is exposed to the global namespace" do
        Kernel.should respond_to("share_as")
      end

      it "adds examples to current example_group using include", :compat => 'rspec-1.2' do
        share_as('Cornucopia') do
          it "is plentiful" do
            5.should eq(4)
          end
        end
        group = ExampleGroup.describe('group') { include Cornucopia }
        phantom_group = group.children.first
        phantom_group.description.should eql("")
        phantom_group.metadata[:shared_group_name].should eql('Cornucopia')
        phantom_group.examples.length.should eq(1)
        phantom_group.examples.first.metadata[:description].should eq("is plentiful")
      end
    end
  end
end
