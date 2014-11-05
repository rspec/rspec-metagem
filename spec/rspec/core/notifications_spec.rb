require 'spec_helper'
require 'rspec/core/notifications'

RSpec.describe "FailedExampleNotification" do
  include FormatterSupport

  let(:notification) { ::RSpec::Core::Notifications::FailedExampleNotification.new(example) }

  before do
    allow(example).to receive(:file_path) { __FILE__ }
  end

  # ported from `base_formatter_spec` should be refactored by final
  describe "#read_failed_line" do
    context "when backtrace is a heterogeneous language stack trace" do
      let(:exception) do
        instance_double(Exception, :backtrace => [
          "at Object.prototypeMethod (foo:331:18)",
          "at Array.forEach (native)",
          "at a_named_javascript_function (/some/javascript/file.js:39:5)",
          "/some/line/of/ruby.rb:14"
        ])
      end

      it "is handled gracefully" do
        expect { notification.send(:read_failed_line) }.not_to raise_error
      end
    end

    context "when backtrace will generate a security error" do
      let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

      it "is handled gracefully" do
        safely do
          expect { notification.send(:read_failed_line) }.not_to raise_error
        end
      end
    end

    context "when ruby reports a bogus line number in the stack trace" do
      let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:10000000"]) }

      it "reports the filename and that it was unable to find the matching line" do
        expect(notification.send(:read_failed_line)).to include("Unable to find matching line")
      end
    end

    context "when String alias to_int to_i" do
      before do
        String.class_exec do
          alias :to_int :to_i
        end
      end

      after do
        String.class_exec do
          undef to_int
        end
      end

      let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

      it "doesn't hang when file exists" do
        expect(notification.send(:read_failed_line).strip).to eql(
          %Q[let(:exception) { instance_double(Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"]) }])
      end

    end
  end

  describe '#message_lines' do
    let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"], :message => 'Test exception') }
    let(:example_group) { class_double(RSpec::Core::ExampleGroup, :metadata => {}, :parent_groups => [], :location => "#{__FILE__}:#{__LINE__}") }

    before do
      allow(example).to receive(:example_group) { example_group }
    end

    it 'should return failure_lines without color' do
      lines = notification.message_lines
      expect(lines[0]).to match %r{\AFailure\/Error}
      expect(lines[1]).to match %r{\A\s*Test exception\z}
    end

    it 'returns failures_lines without color when they are part of a shared example group' do
      example.metadata[:shared_group_inclusion_backtrace] <<
        RSpec::Core::SharedExampleGroupInclusionStackFrame.new("foo", "bar")

      lines = notification.message_lines
      expect(lines[0]).to match %r{\AFailure\/Error}
      expect(lines[1]).to match %r{\A\s*Test exception\z}
    end
  end
end
