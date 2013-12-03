require "spec_helper"

module RSpec::Core
  RSpec.describe Hooks do
    class HooksHost
      include Hooks

      def parent_groups
        []
      end
    end

    [:before, :after, :around].each do |type|
      [:each, :all].each do |scope|
        next if type == :around && scope == :all

        describe "##{type}(#{scope})" do
          it_behaves_like "metadata hash builder" do
            define_method :metadata_hash do |*args|
              instance = HooksHost.new
              args.unshift scope if scope
              hooks = instance.send(type, *args) {}
              hooks.first.options
            end
          end
        end
      end

      describe "##{type}(no scope)" do
        let(:instance) { HooksHost.new }

        it "defaults to :each scope if no arguments are given" do
          hooks = instance.send(type) {}
          hook = hooks.first
          expect(instance.hooks[type][:each]).to include(hook)
        end

        it "defaults to :each scope if the only argument is a metadata hash" do
          hooks = instance.send(type, :foo => :bar) {}
          hook = hooks.first
          expect(instance.hooks[type][:each]).to include(hook)
        end

        it "raises an error if only metadata symbols are given as arguments" do
          expect { instance.send(type, :foo, :bar) {} }.to raise_error(ArgumentError)
        end
      end
    end

    [:before, :after].each do |type|
      [:each, :all, :suite].each do |scope|
        describe "##{type}(#{scope.inspect})" do
          let(:instance) { HooksHost.new }
          let!(:hook) do
            hooks = instance.send(type, scope) {}
            hooks.first
          end

          it "does not make #{scope.inspect} a metadata key" do
            expect(hook.options).to be_empty
          end

          it "is scoped to #{scope.inspect}" do
            expect(instance.hooks[type][scope]).to include(hook)
          end

          it 'does not run when in dry run mode' do
            RSpec.configuration.dry_run = true

            expect { |b|
              instance.send(type, scope, &b)
              instance.hooks.run(type, scope)
            }.not_to yield_control
          end
        end
      end
    end

    describe "#around" do
      context "when not running the example within the around block" do
        it "does not run the example" do
          examples = []
          group = ExampleGroup.describe do
            around do
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          expect(examples).to eq([])
        end
      end

      context "when running the example within the around block" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            around do |example|
              example.run
            end
            it "foo" do
              examples << self
            end
          end
          group.run
          expect(examples.count).to eq(1)
        end

        it "exposes example metadata to each around hook" do
          foos = {}
          group = ExampleGroup.describe do
            around do |ex|
              foos[:first] = ex.metadata[:foo]
              ex.run
            end
            around do |ex|
              foos[:second] = ex.metadata[:foo]
              ex.run
            end
            it "does something", :foo => :bar do
            end
          end

          group.run
          expect(foos).to eq({:first => :bar, :second => :bar})
        end
      end

      context "when running the example within a block passed to a method" do
        it "runs the example" do
          examples = []
          group = ExampleGroup.describe do
            def yielder
              yield
            end

            around do |example|
              yielder { example.run }
            end

            it "foo" do
              examples << self
            end
          end
          group.run
          expect(examples.count).to eq(1)
        end
      end
    end

    [:all, :each].each do |scope|
      describe "prepend_before(#{scope})" do
        it "adds to the front of the list of before(:#{scope}) hooks" do
          messages = []

          RSpec.configure { |config| config.before(scope)         { messages << "config 3" } }
          RSpec.configure { |config| config.prepend_before(scope) { messages << "config 2" } }
          RSpec.configure { |config| config.before(scope)         { messages << "config 4" } }
          RSpec.configure { |config| config.prepend_before(scope) { messages << "config 1" } }

          group = ExampleGroup.describe { example {} }
          group.before(scope)         { messages << "group 3" }
          group.prepend_before(scope) { messages << "group 2" }
          group.before(scope)         { messages << "group 4" }
          group.prepend_before(scope) { messages << "group 1" }

          group.run

          expect(messages).to eq([
            'group 1',
            'group 2',
            'config 1',
            'config 2',
            'config 3',
            'config 4',
            'group 3',
            'group 4'
          ])
        end
      end

      describe "append_before(#{scope})" do
        it "adds to the back of the list of before(:#{scope}) hooks (same as `before`)" do
          messages = []

          RSpec.configure { |config| config.before(scope)        { messages << "config 1" } }
          RSpec.configure { |config| config.append_before(scope) { messages << "config 2" } }
          RSpec.configure { |config| config.before(scope)        { messages << "config 3" } }

          group = ExampleGroup.describe { example {} }
          group.before(scope)        { messages << "group 1" }
          group.append_before(scope) { messages << "group 2" }
          group.before(scope)        { messages << "group 3" }

          group.run

          expect(messages).to eq([
            'config 1',
            'config 2',
            'config 3',
            'group 1',
            'group 2',
            'group 3'
          ])
        end
      end

      describe "prepend_after(#{scope})" do
        it "adds to the front of the list of after(:#{scope}) hooks (same as `after`)" do
          messages = []

          RSpec.configure { |config| config.after(scope)         { messages << "config 3" } }
          RSpec.configure { |config| config.prepend_after(scope) { messages << "config 2" } }
          RSpec.configure { |config| config.after(scope)         { messages << "config 1" } }

          group = ExampleGroup.describe { example {} }
          group.after(scope)         { messages << "group 3" }
          group.prepend_after(scope) { messages << "group 2" }
          group.after(scope)         { messages << "group 1" }

          group.run

          expect(messages).to eq([
            'group 1',
            'group 2',
            'group 3',
            'config 1',
            'config 2',
            'config 3'
          ])
        end
      end

      describe "append_after(#{scope})" do
        it "adds to the back of the list of after(:#{scope}) hooks" do
          messages = []

          RSpec.configure { |config| config.after(scope)        { messages << "config 2" } }
          RSpec.configure { |config| config.append_after(scope) { messages << "config 3" } }
          RSpec.configure { |config| config.after(scope)        { messages << "config 1" } }
          RSpec.configure { |config| config.append_after(scope) { messages << "config 4" } }

          group = ExampleGroup.describe { example {} }
          group.after(scope)        { messages << "group 2" }
          group.append_after(scope) { messages << "group 3" }
          group.after(scope)        { messages << "group 1" }
          group.append_after(scope) { messages << "group 4" }

          group.run

          expect(messages).to eq([
            'group 1',
            'group 2',
            'config 1',
            'config 2',
            'config 3',
            'config 4',
            'group 3',
            'group 4'
          ])
        end
      end
    end

    describe "lambda" do
      it "can be used as a hook" do
        messages = []
        count = 0
        hook = lambda {|e| messages << "hook #{count = count + 1}"; e.run }

        RSpec.configure do |c|
          c.around(:each, &hook)
          c.around(:each, &hook)
        end

        group = ExampleGroup.describe { example { messages << "example" } }
        group.run
        expect(messages).to eq ["hook 1", "hook 2", "example"]
      end
    end

    it "only defines methods that are intended to be part of RSpec's public API (+ `hooks`)" do
      expect(Hooks.private_instance_methods).to eq([])

      expect(Hooks.instance_methods.map(&:to_sym)).to match_array([
        :before, :after, :around,
        :append_before, :append_after,
        :prepend_before, :prepend_after,
        :hooks
      ])
    end
  end
end
