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
      [:example, :context].each do |scope|
        next if type == :around && scope == :context

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

        it "defaults to :example scope if no arguments are given" do
          hooks = instance.send(type) {}
          hook = hooks.first
          expect(instance.hooks[type][:example]).to include(hook)
        end

        it "defaults to :example scope if the only argument is a metadata hash" do
          hooks = instance.send(type, :foo => :bar) {}
          hook = hooks.first
          expect(instance.hooks[type][:example]).to include(hook)
        end

        it "raises an error if only metadata symbols are given as arguments" do
          expect { instance.send(type, :foo, :bar) {} }.to raise_error(ArgumentError)
        end
      end
    end

    [:before, :after].each do |type|
      [:example, :context, :suite].each do |scope|
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
              instance.hooks.run(type, scope, double("Example").as_null_object)
            }.not_to yield_control
          end
        end
      end
    end

    context "when an error happens in `after(:suite)`" do
      it 'allows the error to propagate to the user' do
        RSpec.configuration.after(:suite) { 1 / 0 }

        expect {
          RSpec.configuration.with_suite_hooks { }
        }.to raise_error(ZeroDivisionError)
      end
    end

    context "when an error happens in `before(:suite)`" do
      it 'allows the error to propagate to the user' do
        RSpec.configuration.before(:suite) { 1 / 0 }

        expect {
          RSpec.configuration.with_suite_hooks { }
        }.to raise_error(ZeroDivisionError)
      end
    end

    describe "#around" do
      context "when it does not run the example" do
        context "for a hook declared in the group" do
          it 'converts the example to a skipped example so the user is made aware of it' do
            ex = nil
            group = RSpec.describe do
              around { }
              ex = example("not run") { }
            end

            group.run
            expect(ex.execution_result.status).to eq(:pending)
          end
        end

        context "for a hook declared in config" do
          it 'converts the example to a skipped example so the user is made aware of it' do
            RSpec.configuration.around { }

            ex = nil
            group = RSpec.describe do
              ex = example("not run") { }
            end

            group.run
            expect(ex.execution_result.status).to eq(:pending)
          end
        end

        if RUBY_VERSION.to_f < 1.9
          def hook_desc(_)
            "around hook"
          end
        else
          def hook_desc(line)
            "around hook at #{Metadata.relative_path(__FILE__)}:#{line}"
          end
        end

        it 'indicates which around hook did not run the example in the pending message' do
          ex = nil
          line = __LINE__ + 3
          group = RSpec.describe do
            around { |e| e.run }
            around { }
            around { |e| e.run }

            ex = example("not run") { }
          end

          group.run
          expect(ex.execution_result.pending_message).to eq("#{hook_desc(line)} did not execute the example")
        end
      end

      it 'considers the hook to have run when passed as a block to a method that yields' do
        ex = nil
        group = RSpec.describe do
          def transactionally
            yield
          end

          around { |e| transactionally(&e) }
          ex = example("run") { }
        end

        group.run
        expect(ex.execution_result.status).to eq(:passed)
      end

      it 'does not consider the hook to have run when passed as a block to a method that does not yield' do
        ex = nil
        group = RSpec.describe do
          def transactionally; end

          around { |e| transactionally(&e) }
          ex = example("not run") { }
        end

        group.run
        expect(ex.execution_result.status).to eq(:pending)
      end

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

        it "exposes the full example interface to each around hook" do
          data_1 = {}
          data_2 = {}
          ex     = nil

          group = ExampleGroup.describe do
            def self.data_from(ex)
              {
                :description => ex.description,
                :full_description => ex.full_description,
                :example_group => ex.example_group,
                :file_path => ex.file_path,
                :location => ex.location
              }
            end

            around do |example|
              data_1.update(self.class.data_from example)
              example.run
            end

            around do |example|
              data_2.update(self.class.data_from example)
              example.run
            end

            ex = example("the example") { }
          end

          group.run

          expected_data = group.data_from(ex)
          expect(data_1).to eq(expected_data)
          expect(data_2).to eq(expected_data)
        end

        it "exposes a sensible inspect value" do
          inspect_value = nil
          group = ExampleGroup.describe do
            around do |ex|
              inspect_value = ex.inspect
            end

            it "does something" do
            end
          end

          group.run
          expect(inspect_value).to match(/ExampleProcsy/)
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
