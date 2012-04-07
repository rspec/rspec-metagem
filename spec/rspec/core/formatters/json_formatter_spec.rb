require 'spec_helper'
require 'rspec/core/formatters/json_formatter'
require 'json'
require 'rspec/core/reporter'

describe RSpec::Core::Formatters::JsonFormatter do
  let(:output) { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::JsonFormatter.new(output) }
  let(:reporter) { RSpec::Core::Reporter.new(formatter) }

  it "outputs json (brittle high level functional test)" do
    group = RSpec::Core::ExampleGroup.describe("one apiece") do
      it("succeeds") { 1.should == 1 }
      it("fails") { fail "eek" }
      it("pends") { pending "world peace" }
    end
    succeeding_line = __LINE__ - 4
    failing_line = __LINE__ - 4
    pending_line = __LINE__ - 4

    now = Time.now
    Time.stub(:now).and_return(now)
    reporter.report(2) do |r|
      group.run(r)
    end

    # grab the actual backtrace -- kind of a cheat
    failing_backtrace = formatter.output_hash[:examples][1][:exception][:backtrace]
    this_file = relative_path(__FILE__)

    expected = {
      # :groups => [
      #   :name => "one and one",
      # ],
      :examples => [
        {
          :description => "succeeds",
          :full_description => "one apiece succeeds",
          :status => "passed",
          :file_path => this_file,
          :line_number => succeeding_line,
        },
        {
          :description => "fails",
          :full_description => "one apiece fails",
          :status => "failed",
          :file_path => this_file,
          :line_number => failing_line,
          :exception => {:class => "RuntimeError", :message => "eek", :backtrace => failing_backtrace}

        },
        {
          :description => "pends",
          :full_description => "one apiece pends",
          :status => "pending",
          :file_path => this_file,
          :line_number => pending_line,
        },
        # todo: pending message
      ],
      :summary => {
        :duration => formatter.output_hash[:summary][:duration],
        :example_count => 3,
        :failure_count => 1,
        :pending_count => 1,
      },
      :summary_line => "3 examples, 1 failure, 1 pending"
    }
    formatter.output_hash.should == expected
    output.string.should == expected.to_json
  end

  # todo: include full 'execution_result'

  it "relativizes backtrace paths"

  describe "#stop" do
    it "adds all examples to the output hash" do
      formatter.stop
      formatter.output_hash[:examples].should_not be_nil
    end
  end

  describe "#close" do
    it "outputs the results as a JSON string" do
      output.string.should == ""
      formatter.close
      output.string.should == {}.to_json
    end
  end

  describe "#message" do
    it "adds a message to the messages list" do
      formatter.message("good job")
      formatter.output_hash[:messages].should == ["good job"]
    end
  end

  describe "#dump_summary" do
    it "adds summary info to the output hash" do
      duration, example_count, failure_count, pending_count = 1.0, 2, 1, 1
      formatter.dump_summary(duration, example_count, failure_count, pending_count)
      summary = formatter.output_hash[:summary]
      %w(duration example_count failure_count pending_count).each do |key|
        summary[key.to_sym].should == eval(key)
      end
      summary_line = formatter.output_hash[:summary_line]
      summary_line.should == "2 examples, 1 failure, 1 pending"
    end
  end
end


  # describe "#dump_commands_to_rerun_failed_examples" do
  #   it "includes command to re-run each failed example" do
  #     group = RSpec::Core::ExampleGroup.describe("example group") do
  #       it("fails") { fail }
  #     end
  #     line = __LINE__ - 2
  #     group.run(formatter)
  #     formatter.dump_commands_to_rerun_failed_examples
  #     output.string.should include("rspec #{RSpec::Core::Metadata::relative_path("#{__FILE__}:#{line}")} # example group fails")
  #   end
  # end

=begin

  describe "#dump_failures" do
    let(:group) { RSpec::Core::ExampleGroup.describe("group name") }

    before { RSpec.configuration.stub(:color_enabled?) { false } }

    def run_all_and_dump_failures
      group.run(formatter)
      formatter.dump_failures
    end

    it "preserves formatting" do
      group.example("example name") { "this".should eq("that") }

      run_all_and_dump_failures

      output.string.should =~ /group name example name/m
      output.string.should =~ /(\s+)expected: \"that\"\n\1     got: \"this\"/m
    end

    context "with an exception without a message" do
      it "does not throw NoMethodError" do
        exception_without_message = Exception.new()
        exception_without_message.stub(:message) { nil }
        group.example("example name") { raise exception_without_message }
        expect { run_all_and_dump_failures }.not_to raise_error(NoMethodError)
      end

      it "preserves ancestry" do
        example = group.example("example name") { raise "something" }
        run_all_and_dump_failures
        example.example_group.ancestors.size.should == 1
      end
    end

    context "with an exception class other than RSpec" do
      it "does not show the error class" do
        group.example("example name") { raise NameError.new('foo') }
        run_all_and_dump_failures
        output.string.should =~ /NameError/m
      end
    end

    context "with a failed expectation (rspec-expectations)" do
      it "does not show the error class" do
        group.example("example name") { "this".should eq("that") }
        run_all_and_dump_failures
        output.string.should_not =~ /RSpec/m
      end
    end

    context "with a failed message expectation (rspec-mocks)" do
      it "does not show the error class" do
        group.example("example name") { "this".should_receive("that") }
        run_all_and_dump_failures
        output.string.should_not =~ /RSpec/m
      end
    end

    context 'for #share_examples_for' do
      it 'outputs the name and location' do

        share_examples_for 'foo bar' do
          it("example name") { "this".should eq("that") }
        end

        line = __LINE__.next
        group.it_should_behave_like('foo bar')

        run_all_and_dump_failures

        output.string.should include(
          'Shared Example Group: "foo bar" called from ' +
            "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
        )
      end

      context 'that contains nested example groups' do
        it 'outputs the name and location' do
          share_examples_for 'foo bar' do
            describe 'nested group' do
              it("example name") { "this".should eq("that") }
            end
          end

          line = __LINE__.next
          group.it_should_behave_like('foo bar')

          run_all_and_dump_failures

          output.string.should include(
            'Shared Example Group: "foo bar" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end
      end
    end

    context 'for #share_as' do
      it 'outputs the name and location' do

        share_as :FooBar do
          it("example name") { "this".should eq("that") }
        end

        line = __LINE__.next
        group.send(:include, FooBar)

        run_all_and_dump_failures

        output.string.should include(
          'Shared Example Group: "FooBar" called from ' +
            "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
        )
      end

      context 'that contains nested example groups' do
        it 'outputs the name and location' do

          share_as :NestedFoo do
            describe 'nested group' do
              describe 'hell' do
                it("example name") { "this".should eq("that") }
              end
            end
          end

          line = __LINE__.next
          group.send(:include, NestedFoo)

          run_all_and_dump_failures

          output.string.should include(
            'Shared Example Group: "NestedFoo" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end
      end
    end
  end

  describe "#dump_pending" do
    let(:group) { RSpec::Core::ExampleGroup.describe("group name") }

    before { RSpec.configuration.stub(:color_enabled?) { false } }

    def run_all_and_dump_pending
      group.run(formatter)
      formatter.dump_pending
    end

    context "with show_failures_in_pending_blocks setting enabled" do
      before { RSpec.configuration.stub(:show_failures_in_pending_blocks?) { true } }

      it "preserves formatting" do
        group.example("example name") { pending { "this".should eq("that") } }

        run_all_and_dump_pending

        output.string.should =~ /group name example name/m
        output.string.should =~ /(\s+)expected: \"that\"\n\1     got: \"this\"/m
      end

      context "with an exception without a message" do
        it "does not throw NoMethodError" do
          exception_without_message = Exception.new()
          exception_without_message.stub(:message) { nil }
          group.example("example name") { pending { raise exception_without_message } }
          expect { run_all_and_dump_pending }.not_to raise_error(NoMethodError)
        end
      end

      context "with an exception class other than RSpec" do
        it "does not show the error class" do
          group.example("example name") { pending { raise NameError.new('foo') } }
          run_all_and_dump_pending
          output.string.should =~ /NameError/m
        end
      end

      context "with a failed expectation (rspec-expectations)" do
        it "does not show the error class" do
          group.example("example name") { pending { "this".should eq("that") } }
          run_all_and_dump_pending
          output.string.should_not =~ /RSpec/m
        end
      end

      context "with a failed message expectation (rspec-mocks)" do
        it "does not show the error class" do
          group.example("example name") { pending { "this".should_receive("that") } }
          run_all_and_dump_pending
          output.string.should_not =~ /RSpec/m
        end
      end

      context 'for #share_examples_for' do
        it 'outputs the name and location' do

          share_examples_for 'foo bar' do
            it("example name") { pending { "this".should eq("that") } }
          end

          line = __LINE__.next
          group.it_should_behave_like('foo bar')

          run_all_and_dump_pending

          output.string.should include(
            'Shared Example Group: "foo bar" called from ' +
            "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end

        context 'that contains nested example groups' do
          it 'outputs the name and location' do
            share_examples_for 'foo bar' do
              describe 'nested group' do
                it("example name") { pending { "this".should eq("that") } }
              end
            end

            line = __LINE__.next
            group.it_should_behave_like('foo bar')

            run_all_and_dump_pending

            output.string.should include(
              'Shared Example Group: "foo bar" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
            )
          end
        end
      end

      context 'for #share_as' do
        it 'outputs the name and location' do

          share_as :FooBar2 do
            it("example name") { pending { "this".should eq("that") } }
          end

          line = __LINE__.next
          group.send(:include, FooBar2)

          run_all_and_dump_pending

          output.string.should include(
            'Shared Example Group: "FooBar2" called from ' +
            "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end

        context 'that contains nested example groups' do
          it 'outputs the name and location' do

            share_as :NestedFoo2 do
              describe 'nested group' do
                describe 'hell' do
                  it("example name") { pending { "this".should eq("that") } }
                end
              end
            end

            line = __LINE__.next
            group.send(:include, NestedFoo2)

            run_all_and_dump_pending

            output.string.should include(
              'Shared Example Group: "NestedFoo2" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
            )
          end
        end
      end
    end

    context "with show_failures_in_pending_blocks setting disabled" do
      before { RSpec.configuration.stub(:show_failures_in_pending_blocks?) { false } }

      it "does not output the failure information" do
        group.example("example name") { pending { "this".should eq("that") } }
        run_all_and_dump_pending
        output.string.should_not =~ /(\s+)expected: \"that\"\n\1     got: \"this\"/m
      end
    end
  end

  describe "#dump_profile" do
    before do
      formatter.stub(:examples) do
        group = RSpec::Core::ExampleGroup.describe("group") do
          example("example")
        end
        group.run(double('reporter').as_null_object)
        group.examples
      end
    end

    it "names the example" do
      formatter.dump_profile
      output.string.should =~ /group example/m
    end

    it "prints the time" do
      formatter.dump_profile
      output.string.should =~ /0(\.\d+)? seconds/
    end

    it "prints the path" do
      formatter.dump_profile
      filename = __FILE__.split(File::SEPARATOR).last

      output.string.should =~ /#{filename}\:#{__LINE__ - 21}/
    end
  end
end
=end
