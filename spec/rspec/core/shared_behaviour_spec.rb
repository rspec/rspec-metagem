require 'spec_helper'

describe Rspec::Core::SharedBehaviour do

  it "should add the 'share_examples_for' method to the global namespace" do
    Kernel.should respond_to(:share_examples_for)
  end

  it "should add the 'shared_examples_for' method to the global namespace" do
    Kernel.should respond_to(:shared_examples_for)
  end

  it "should add the 'share_as' method to the global namespace" do
    Kernel.should respond_to(:share_as)
  end

  it "should raise an ArgumentError when adding a second shared behaviour with the same name" do
    group = isolated_example_group('example group')
    group.share_examples_for('really important business value') { }
    lambda do
      group.share_examples_for('really important business value') { }
    end.should raise_error(ArgumentError, "Shared example group 'really important business value' already exists")
  end

  describe "share_examples_for" do

    it "should capture the given name and block in the Worlds collection of shared behaviours" do
      Rspec::Core.world.shared_behaviours.should_receive(:[]=).with(:foo, anything)
      share_examples_for(:foo) { }
    end

  end

  describe "including shared behaviours using #it_should_behave_like" do

    def cleanup_shared_behaviours
      original_shared_behaviours = Rspec::Core.world.shared_behaviours
      yield if block_given?
      Rspec::Core.world.shared_behaviours.replace(original_shared_behaviours)
    end

    it "should module_eval any found shared behaviours" do
      group = isolated_example_group('fake group')
      block1 = lambda {}
      block2 = lambda {
        def extra_helper
          'extra_helper'
        end
      }
      Rspec::Core.world.stub!(:shared_behaviours).and_return({ :a => block1, :shared_behaviour => block2 })
      group.should_receive(:module_eval).once
      group.it_should_behave_like :shared_behaviour
    end

    it "should make any shared behaviour available at the correct level" do
      group = isolated_example_group('fake group')
      block = lambda {
        def self.class_helper; end
        def extra_helper; end
      }
      Rspec::Core.world.stub!(:shared_behaviours).and_return({ :shared_behaviour => block })
      group.it_should_behave_like :shared_behaviour
      with_ruby(1.8) do
        group.instance_methods.should include('extra_helper')
        group.singleton_methods.should include('class_helper')
      end
      with_ruby(1.9) do
        group.instance_methods.should include(:extra_helper)
        group.singleton_methods.should include(:class_helper)
      end
    end

    it "should raise when named shared example_group can not be found" 

    it "adds examples to current example_group using it_should_behave_like" do
      cleanup_shared_behaviours do
        group = isolated_example_group("example_group") do
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
      cleanup_shared_behaviours do
        group = isolated_example_group("example_group") do |g|
          g.it("i was already here") {}
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
      it "should do foo" do; end
    end

    pending "adds examples to current example_group using include", :compat => 'rspec-1.2' do
      group = isolated_example_group('group') { include Cornucopia }
      group.examples.length.should == 1
    end

    it "adds examples to current example_group using it_should_behave_like with a module" do
      cleanup_shared_behaviours do
        group = isolated_example_group("example_group")  {}

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
        running_example.behaviour.included_modules.should include(RunningSharedExamplesJustForTesting)
      end

      it "should make methods defined in the shared example_group available in consuming example_group", :compat => 'rspec-1.2' do
        # TODO: Consider should have_method(...) simple matcher
        with_ruby('1.8') { running_example.behaviour.methods.should include('magic') }
        with_ruby('1.9') { running_example.behaviour.methods.should include(:magic) }
      end

    end

  end


end
