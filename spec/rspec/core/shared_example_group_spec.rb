require 'spec_helper'

module Rspec::Core

  describe SharedExampleGroup do

    it "should add the 'share_examples_for' method to the global namespace" do
      Kernel.should respond_to(:share_examples_for)
    end

    it "should add the 'shared_examples_for' method to the global namespace" do
      Kernel.should respond_to(:shared_examples_for)
    end

    it "should add the 'share_as' method to the global namespace" do
      Kernel.should respond_to(:share_as)
    end

    it "should raise an ArgumentError when adding a second shared example group with the same name" do
      group = ExampleGroup.create('example group')
      group.share_examples_for('really important business value') { }
      lambda do
        group.share_examples_for('really important business value') { }
      end.should raise_error(ArgumentError, "Shared example group 'really important business value' already exists")
    end

    describe "share_examples_for" do

      it "should capture the given name and block in the Worlds collection of shared example groups" do
        Rspec::Core.world.shared_example_groups.should_receive(:[]=).with(:foo, anything)
        share_examples_for(:foo) { }
      end

    end

    describe "including shared example_groups using #it_should_behave_like" do

      def cleanup_shared_example_groups
        original_shared_example_groups = Rspec::Core.world.shared_example_groups
        yield if block_given?
        Rspec::Core.world.shared_example_groups.replace(original_shared_example_groups)
      end

      it "should make any shared example_group available at the correct level", :ruby => 1.8 do
        group = ExampleGroup.create('fake group')
        block = lambda {
          def self.class_helper; end
          def extra_helper; end
        }
        Rspec::Core.world.stub(:shared_example_groups).and_return({ :shared_example_group => block })
        group.it_should_behave_like :shared_example_group
        group.instance_methods.should  include('extra_helper')
        group.singleton_methods.should include('class_helper')
      end

      it "should make any shared example_group available at the correct level", :ruby => 1.9 do
        group = ExampleGroup.create('fake group')
        block = lambda {
          def self.class_helper; end
          def extra_helper; end
        }
        Rspec::Core.world.stub(:shared_example_groups).and_return({ :shared_example_group => block })
        group.it_should_behave_like :shared_example_group
        group.instance_methods.should include(:extra_helper)
        group.singleton_methods.should include(:class_helper)
      end

      it "should raise when named shared example_group can not be found" 

      it "adds examples to current example_group using it_should_behave_like" do
        cleanup_shared_example_groups do
          group = ExampleGroup.create("example_group") do
            it("i was already here") {}
          end

          group.examples.size.should == 1

          group.share_examples_for('shared example_group') do
            it("shared example") {}
            it("shared example 2") {}
          end

          group.it_should_behave_like("shared example_group")

          group.examples.size.should == 3
        end
      end

      it "adds examples to from two shared groups" do
        cleanup_shared_example_groups do
          group = ExampleGroup.create("example_group") do
            it("i was already here") {}
          end

          group.examples.size.should == 1

          group.share_examples_for('test 2 shared groups') do
            it("shared example") {}
            it("shared example 2") {}
          end

          group.share_examples_for('test 2 shared groups 2') do
            it("shared example 3") {}
          end

          group.it_should_behave_like("test 2 shared groups")
          group.it_should_behave_like("test 2 shared groups 2")

          group.examples.size.should == 4
        end
      end

      share_as('Cornucopia') do
        it "is plentiful" do
          5.should == 4
        end
      end

      it "adds examples to current example_group using include", :compat => 'rspec-1.2' do
        group = ExampleGroup.create('group') { include Cornucopia }
        group.examples.length.should == 1
        group.examples.first.metadata[:description].should == "is plentiful"
      end

      it "adds examples to current example_group using it_should_behave_like with a module" do
        cleanup_shared_example_groups do
          group = ExampleGroup.create("example_group")  {}

          shared_foo = group.share_as(:FooShared) do
            it("shared example") {}
          end

          group.it_should_behave_like(::FooShared) 

          group.examples.size.should == 1
        end
      end

      describe "running shared examples" do
        module RunningSharedExamplesJustForTesting; end

        share_examples_for("it runs shared examples") do
          include RunningSharedExamplesJustForTesting

          def magic
            @magic ||= {}
          end

          before(:each) { magic[:before_each] = 'each' }
          after(:each)  { magic[:after_each] = 'each' }
          before(:all)  { magic[:before_all] = 'all' }
        end

        it_should_behave_like "it runs shared examples"

        it "runs before(:each) from shared example_group", :compat => 'rspec-1.2' do
          magic[:before_each].should == 'each'
        end

        it "runs after(:each) from shared example_group", :compat => 'rspec-1.2' 

        it "should run before(:all) only once from shared example_group", :compat => 'rspec-1.2' do
          magic[:before_all].should == 'all'
        end

        it "should run after(:all) only once from shared example_group", :compat => 'rspec-1.2' 

        it "should include modules, included into shared example_group, into current example_group", :compat => 'rspec-1.2' do
          running_example.example_group.included_modules.should include(RunningSharedExamplesJustForTesting)
        end

        it "should make methods defined in the shared example_group available in consuming example_group", :compat => 'rspec-1.2' do
          magic.should be_a(Hash)
        end

      end

    end

  end

end
