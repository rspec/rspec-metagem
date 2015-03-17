require 'pp'
require 'stringio'

RSpec.describe RSpec::Core::Example, :parent_metadata => 'sample' do

  let(:example_group) do
    RSpec.describe('group description')
  end

  let(:example_instance) do
    example_group.example('example description') { }
  end

  it_behaves_like "metadata hash builder" do
    def metadata_hash(*args)
      example = example_group.example('example description', *args)
      example.metadata
    end
  end

  it "can be pretty printed" do
    expect { ignoring_warnings { pp example_instance }}.to output(/RSpec::Core::Example/).to_stdout
  end

  describe "#rerun_argument" do
    it "returns the location-based rerun argument" do
      allow(RSpec.configuration).to receive_messages(:loaded_spec_files => [__FILE__])
      example = RSpec.describe.example
      expect(example.rerun_argument).to eq("#{RSpec::Core::Metadata.relative_path(__FILE__)}:#{__LINE__ - 1}")
    end
  end

  describe "#exception" do
    it "supplies the first exception raised, if any" do
      RSpec.configuration.output_stream = StringIO.new

      example = example_group.example { raise "first" }
      example_group.after { raise "second" }
      example_group.run
      expect(example.exception.message).to eq("first")
    end

    it "returns nil if there is no exception" do
      example = example_group.example('example') { }
      example_group.run
      expect(example.exception).to be_nil
    end
  end

  describe "when there is an explicit description" do
    context "when RSpec.configuration.format_docstrings is set to a block" do
      it "formats the description using the block" do
        RSpec.configuration.format_docstrings { |s| s.strip }
        example = example_group.example(' an example with whitespace ') {}
        example_group.run
        expect(example.description).to eql('an example with whitespace')
      end
    end
  end

  describe "when there is no explicit description" do
    def expect_with(*frameworks)
      if frameworks.include?(:stdlib)
        example_group.class_exec do
          def assert(val)
            raise "Expected #{val} to be true" unless val
          end
        end
      end
    end

    context "when RSpec.configuration.format_docstrings is set to a block" do
      it "formats the description using the block" do
        RSpec.configuration.format_docstrings { |s| s.upcase }
        example_group.example { }
        example_group.run
        pattern = /EXAMPLE AT #{relative_path(__FILE__).upcase}:#{__LINE__ - 2}/
        expect(example_group.examples.first.description).to match(pattern)
      end
    end

    context "when `expect_with :rspec` is configured" do
      before(:each) { expect_with :rspec }

      it "uses the matcher-generated description" do
        example_group.example { expect(5).to eq(5) }
        example_group.run
        expect(example_group.examples.first.description).to eq("should eq 5")
      end

      it "uses the matcher-generated description in the full description" do
        example_group.example { expect(5).to eq(5) }
        example_group.run
        expect(example_group.examples.first.full_description).to eq("group description should eq 5")
      end

      it "uses the file and line number if there is no matcher-generated description" do
        example = example_group.example {}
        example_group.run
        expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 2}/)
      end

      it "uses the file and line number if there is an error before the matcher" do
        example = example_group.example { expect(5).to eq(5) }
        example_group.before { raise }
        example_group.run
        expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 3}/)
      end

      context "if the example is pending" do
        it "still uses the matcher-generated description if a matcher ran" do
          example = example_group.example { pending; expect(4).to eq(5) }
          example_group.run
          expect(example.description).to eq("should eq 5")
        end

        it "uses the file and line number of the example if no matcher ran" do
          example = example_group.example { pending; fail }
          example_group.run
          expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 2}/)
        end
      end

      context "when an `after(:example)` hook raises an error" do
        it 'still assigns the description' do
          ex = nil

          RSpec.describe do
            ex = example { expect(2).to eq(2) }
            after { raise "boom" }
          end.run

          expect(ex.description).to eq("should eq 2")
        end
      end

      context "when the matcher's `description` method raises an error" do
        description_line = __LINE__ + 3
        RSpec::Matchers.define :matcher_with_failing_description do
          match { true }
          description { raise ArgumentError, "boom" }
        end

        it 'allows the example to pass and surfaces the failing description in the example description' do
          ex = nil

          RSpec.describe do
            ex = example { expect(2).to matcher_with_failing_description }
          end.run

          expect(ex).to pass.and have_attributes(:description => a_string_including(
            "example at #{ex.location}",
            "ArgumentError",
            "boom",
            "#{__FILE__}:#{description_line}"
          ))
        end
      end

      context "when an `after(:example)` hook has an expectation" do
        it "assigns the description based on the example's last expectation, ignoring the `after` expectation since it can apply to many examples" do
          ex = nil

          RSpec.describe do
            ex = example { expect(nil).to be_nil }
            after { expect(true).to eq(true) }
          end.run

          expect(ex).to pass.and have_attributes(:description => "should be nil")
        end
      end
    end

    context "when `expect_with :rspec, :stdlib` is configured" do
      before(:each) { expect_with :rspec, :stdlib }

      it "uses the matcher-generated description" do
        example_group.example { expect(5).to eq(5) }
        example_group.run
        expect(example_group.examples.first.description).to eq("should eq 5")
      end

      it "uses the file and line number if there is no matcher-generated description" do
        example = example_group.example {}
        example_group.run
        expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 2}/)
      end

      it "uses the file and line number if there is an error before the matcher" do
        example = example_group.example { expect(5).to eq(5) }
        example_group.before { raise }
        example_group.run
        expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 3}/)
      end
    end

    context "when `expect_with :stdlib` is configured" do
      around do |ex|
        # Prevent RSpec::Matchers from being autoloaded.
        orig_autoloads = RSpec::MODULES_TO_AUTOLOAD.dup
        RSpec::MODULES_TO_AUTOLOAD.clear
        ex.run
        RSpec::MODULES_TO_AUTOLOAD.replace(orig_autoloads)
      end

      before { expect_with :stdlib }

      it "does not attempt to get the generated description from RSpec::Matchers when not loaded" do
        # Hide the constant while the example runs to simulate it being unloaded.
        example_group.before { hide_const("RSpec::Matchers") }

        ex = example_group.example { assert 5 == 5 }
        example_group.run

        # We rescue errors that occur while generating the description and append it,
        # so this ensures that no error mentioning `RSpec::Matchers` occurred while
        # generating the description.
        expect(ex.description).not_to include("RSpec::Matchers")
        expect(ex).to pass
      end

      it "uses the file and line number" do
        example = example_group.example { assert 5 == 5 }
        example_group.run
        expect(example.description).to match(/example at #{relative_path(__FILE__)}:#{__LINE__ - 2}/)
      end
    end
  end

  describe "#described_class" do
    it "returns the class (if any) of the outermost example group" do
      expect(described_class).to eq(RSpec::Core::Example)
    end
  end

  describe "accessing metadata within a running example" do
    it "has a reference to itself when running" do |ex|
      expect(ex.description).to eq("has a reference to itself when running")
    end

    it "can access the example group's top level metadata as if it were its own" do |ex|
      expect(ex.example_group.metadata).to include(:parent_metadata => 'sample')
      expect(ex.metadata).to include(:parent_metadata => 'sample')
    end
  end

  describe "accessing options within a running example" do
    it "can look up option values by key", :demo => :data do |ex|
      expect(ex.metadata[:demo]).to eq(:data)
    end
  end

  describe "#run" do
    it "sets its reference to the example group instance to nil" do
      group = RSpec.describe do
        example('example') { expect(1).to eq(1) }
      end
      group.run
      expect(group.examples.first.instance_variable_get("@example_group_instance")).to be_nil
    end

    it "generates a description before tearing down mocks in case a mock object is used in the description" do
      group = RSpec.describe do
        example { test = double('Test'); expect(test).to eq test }
      end

      expect(RSpec::Matchers).to receive(:generated_description).and_call_original.ordered
      expect(RSpec::Mocks).to receive(:teardown).and_call_original.ordered

      group.run
    end

    it "runs after(:each) when the example passes" do
      after_run = false
      group = RSpec.describe do
        after(:each) { after_run = true }
        example('example') { expect(1).to eq(1) }
      end
      group.run
      expect(after_run).to be_truthy, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example fails" do
      after_run = false
      group = RSpec.describe do
        after(:each) { after_run = true }
        example('example') { expect(1).to eq(2) }
      end
      group.run
      expect(after_run).to be_truthy, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example raises an Exception" do
      after_run = false
      group = RSpec.describe do
        after(:each) { after_run = true }
        example('example') { raise "this error" }
      end
      group.run
      expect(after_run).to be_truthy, "expected after(:each) to be run"
    end

    context "with an after(:each) that raises" do
      it "runs subsequent after(:each)'s" do
        after_run = false
        group = RSpec.describe do
          after(:each) { after_run = true }
          after(:each) { raise "FOO" }
          example('example') { expect(1).to eq(1) }
        end
        group.run
        expect(after_run).to be_truthy, "expected after(:each) to be run"
      end

      it "stores the exception" do
        group = RSpec.describe
        group.after(:each) { raise "FOO" }
        example = group.example('example') { expect(1).to eq(1) }

        group.run

        expect(example.execution_result.exception.message).to eq("FOO")
      end
    end

    it "wraps before/after(:each) inside around" do
      results = []
      group = RSpec.describe do
        around(:each) do |e|
          results << "around (before)"
          e.run
          results << "around (after)"
        end
        before(:each) { results << "before" }
        after(:each) { results << "after" }
        example { results << "example" }
      end

      group.run
      expect(results).to eq([
                          "around (before)",
                          "before",
                          "example",
                          "after",
                          "around (after)"
                        ])
    end

    context "clearing ivars" do
      it "sets ivars to nil to prep them for GC" do
        group = RSpec.describe do
          before(:all)  { @before_all  = :before_all }
          before(:each) { @before_each = :before_each }
          after(:each)  { @after_each = :after_each }
          after(:all)   { @after_all  = :after_all }
        end
        group.example("does something") do
          expect(@before_all).to eq(:before_all)
          expect(@before_each).to eq(:before_each)
        end
        expect(group.run(double.as_null_object)).to be_truthy
        group.new do |example|
          %w[@before_all @before_each @after_each @after_all].each do |ivar|
            expect(example.instance_variable_get(ivar)).to be_nil
          end
        end
      end

      it "does not impact the before_all_ivars which are copied to each example" do
        group = RSpec.describe do
          before(:all) { @before_all = "abc" }
          example("first") { expect(@before_all).not_to be_nil }
          example("second") { expect(@before_all).not_to be_nil }
        end
        expect(group.run).to be_truthy
      end
    end

    context 'when the example raises an error' do
      def run_and_capture_reported_message(group)
        reported_msg = nil
        # We can't use should_receive(:message).with(/.../) here,
        # because if that fails, it would fail within our example-under-test,
        # and since there's already two errors, it would just be reported again.
        allow(RSpec.configuration.reporter).to receive(:message) { |msg| reported_msg = msg }
        group.run
        reported_msg
      end

      it "prints any around hook errors rather than silencing them" do
        group = RSpec.describe do
          around(:each) { |e| e.run; raise "around" }
          example("e") { raise "example" }
        end

        message = run_and_capture_reported_message(group)
        expect(message).to match(/An error occurred in an `around.* hook/i)
      end

      it "prints any after hook errors rather than silencing them" do
        group = RSpec.describe do
          after(:each) { raise "after" }
          example("e") { raise "example" }
        end

        message = run_and_capture_reported_message(group)
        expect(message).to match(/An error occurred in an after.* hook/i)
      end

      it "does not print mock expectation errors" do
        group = RSpec.describe do
          example do
            foo = double
            expect(foo).to receive(:bar)
            raise "boom"
          end
        end

        message = run_and_capture_reported_message(group)
        expect(message).to be_nil
      end

      it "leaves a raised exception unmodified (GH-1103)" do
        # set the backtrace, otherwise MRI will build a whole new object,
        # and thus mess with our expectations. Rubinius and JRuby are not
        # affected.
        exception = StandardError.new
        exception.set_backtrace([])

        group = RSpec.describe do
          example { raise exception.freeze }
        end
        group.run

        actual = group.examples.first.execution_result.exception
        expect(actual.__id__).to eq(exception.__id__)
      end
    end

    context "with --dry-run" do
      before { RSpec.configuration.dry_run = true }

      it "does not execute any examples or hooks" do
        executed = []

        RSpec.configure do |c|
          c.before(:each) { executed << :before_each_config }
          c.before(:all)  { executed << :before_all_config }
          c.after(:each)  { executed << :after_each_config }
          c.after(:all)   { executed << :after_all_config }
          c.around(:each) { |ex| executed << :around_each_config; ex.run }
        end

        group = RSpec.describe do
          before(:all)  { executed << :before_all }
          before(:each) { executed << :before_each }
          after(:all)   { executed << :after_all }
          after(:each)  { executed << :after_each }
          around(:each) { |ex| executed << :around_each; ex.run }

          example { executed << :example }

          context "nested" do
            before(:all)  { executed << :nested_before_all }
            before(:each) { executed << :nested_before_each }
            after(:all)   { executed << :nested_after_all }
            after(:each)  { executed << :nested_after_each }
            around(:each) { |ex| executed << :nested_around_each; ex.run }

            example { executed << :nested_example }
          end
        end

        group.run
        expect(executed).to eq([])
      end
    end
  end

  describe "#pending" do
    def expect_pending_result(example)
      expect(example).to be_pending
      expect(example.execution_result.status).to eq(:pending)
      expect(example.execution_result.pending_message).to be
    end

    context "in the example" do
      it "sets the example to pending" do
        group = RSpec.describe do
          example { pending; fail }
        end
        group.run
        expect_pending_result(group.examples.first)
      end

      it "allows post-example processing in around hooks (see https://github.com/rspec/rspec-core/issues/322)" do
        blah = nil
        group = RSpec.describe do
          around do |example|
            example.run
            blah = :success
          end
          example { pending }
        end
        group.run
        expect(blah).to be(:success)
      end

      it 'sets the backtrace to the example definition so it can be located by the user' do
        file = RSpec::Core::Metadata.relative_path(__FILE__)
        expected = [file, __LINE__ + 2].map(&:to_s)
        group = RSpec.describe do
          example {
            pending
          }
        end
        group.run

        actual = group.examples.first.exception.backtrace.first.split(':')[0..1]
        expect(actual).to eq(expected)
      end
    end

    context "in before(:each)" do
      it "sets each example to pending" do
        group = RSpec.describe do
          before(:each) { pending }
          example { fail }
          example { fail }
        end
        group.run
        expect_pending_result(group.examples.first)
        expect_pending_result(group.examples.last)
      end

      it 'sets example to pending when failure occurs in before(:each)' do
        group = RSpec.describe do
          before(:each) { pending; fail }
          example {}
        end
        group.run
        expect_pending_result(group.examples.first)
      end
    end

    context "in before(:all)" do
      it "is forbidden" do
        group = RSpec.describe do
          before(:all) { pending }
          example { fail }
          example { fail }
        end
        group.run
        expect(group.examples.first.exception).to be
        expect(group.examples.first.exception.message).to \
          match(/may not be used outside of examples/)
      end

      it "fails with an ArgumentError if a block is provided" do
        group = RSpec.describe('group') do
          before(:all) do
            pending { :no_op }
          end
          example { fail }
        end
        example = group.examples.first
        group.run
        expect(example).to fail_with ArgumentError
        expect(example.exception.message).to match(
          /Passing a block within an example is now deprecated./
        )
      end
    end

    context "in around(:each)" do
      it "sets the example to pending" do
        group = RSpec.describe do
          around(:each) { pending }
          example { fail }
        end
        group.run
        expect_pending_result(group.examples.first)
      end

      it 'sets example to pending when failure occurs in around(:each)' do
        group = RSpec.describe do
          around(:each) { pending; fail }
          example {}
        end
        group.run
        expect_pending_result(group.examples.first)
      end
    end

    context "in after(:each)" do
      it "sets each example to pending" do
        group = RSpec.describe do
          after(:each) { pending; fail }
          example { }
          example { }
        end
        group.run
        expect_pending_result(group.examples.first)
        expect_pending_result(group.examples.last)
      end
    end

  end

  describe "#skip" do
    context "in the example" do
      it "sets the example to skipped" do
        group = RSpec.describe do
          example { skip }
        end
        group.run
        expect(group.examples.first).to be_skipped
      end

      it "allows post-example processing in around hooks (see https://github.com/rspec/rspec-core/issues/322)" do
        blah = nil
        group = RSpec.describe do
          around do |example|
            example.run
            blah = :success
          end
          example { skip }
        end
        group.run
        expect(blah).to be(:success)
      end

      context "with a message" do
        it "sets the example to skipped with the provided message" do
          group = RSpec.describe do
            example { skip "lorem ipsum" }
          end
          group.run
          expect(group.examples.first).to be_skipped_with("lorem ipsum")
        end
      end
    end

    context "in before(:each)" do
      it "sets each example to skipped" do
        group = RSpec.describe do
          before(:each) { skip }
          example {}
          example {}
        end
        group.run
        expect(group.examples.first).to be_skipped
        expect(group.examples.last).to be_skipped
      end
    end

    context "in before(:all)" do
      it "sets each example to skipped" do
        group = RSpec.describe do
          before(:all) { skip("not done"); fail }
          example {}
          example {}
        end
        group.run
        expect(group.examples.first).to be_skipped_with("not done")
        expect(group.examples.last).to be_skipped_with("not done")
      end
    end

    context "in around(:each)" do
      it "sets the example to skipped" do
        group = RSpec.describe do
          around(:each) { skip }
          example {}
        end
        group.run
        expect(group.examples.first).to be_skipped
      end
    end
  end

  describe "timing" do
    it "uses RSpec::Core::Time as to not be affected by changes to time in examples" do
      reporter = double(:reporter).as_null_object
      group = RSpec.describe
      example = group.example
      example.__send__ :start, reporter
      allow(Time).to receive_messages(:now => Time.utc(2012, 10, 1))
      example.__send__ :finish, reporter
      expect(example.execution_result.run_time).to be < 0.2
    end
  end

  it "does not interfere with per-example randomness when running examples in a random order" do
    values = []

    RSpec.configuration.order = :random

    RSpec.describe do
      # The bug was only triggered when the examples
      # were in nested contexts; see https://github.com/rspec/rspec-core/pull/837
      context { example { values << rand } }
      context { example { values << rand } }
    end.run

    expect(values.uniq.count).to eq(2)
  end

  describe "optional block argument" do
    it "contains the example" do |ex|
      expect(ex).to be_an(RSpec::Core::Example)
      expect(ex.description).to match(/contains the example/)
    end
  end

  describe "setting the current example" do
    it "sets RSpec.current_example to the example that is currently running" do
      group = RSpec.describe("an example group")

      current_examples = []
      example1 = group.example("example 1") { current_examples << RSpec.current_example }
      example2 = group.example("example 2") { current_examples << RSpec.current_example }

      group.run
      expect(current_examples).to eq([example1, example2])
    end
  end

  describe "mock framework integration" do
    it 'verifies mock expectations after each example' do
      ex = nil

      RSpec.describe do
        let(:dbl) { double }
        ex = example do
          expect(dbl).to receive(:foo)
        end
      end.run

      expect(ex).to fail_with(RSpec::Mocks::MockExpectationError)
    end

    it 'allows `after(:example)` hooks to satisfy mock expectations, since examples are not complete until their `after` hooks run' do
      ex = nil

      RSpec.describe do
        let(:dbl) { double }

        ex = example do
          expect(dbl).to receive(:foo)
        end

        after { dbl.foo }
      end.run

      expect(ex).to pass
    end
  end

  describe "exposing the examples reporter" do
    it "returns a null reporter when the example hasnt run yet" do
      example = RSpec.describe.example
      expect(example.reporter).to be RSpec::Core::NullReporter
    end

    it "returns the reporter used to run the example when executed" do
      reporter = double(:reporter).as_null_object
      group = RSpec.describe
      example = group.example
      example.run group.new, reporter
      expect(example.reporter).to be reporter
    end
  end
end
