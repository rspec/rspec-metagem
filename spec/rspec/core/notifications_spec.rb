require 'spec_helper'
require 'rspec/core/notifications'

RSpec.describe "FailedExampleNotification" do
  # ported from `base_formatter_spec` should be refactored by final
  describe "#read_failed_line" do
    let(:example) { double(:Example, :file_path => __FILE__, :execution_result => double(:exception => exception)) }
    let(:notification) { ::RSpec::Core::Notifications::FailedExampleNotification.new(example) }

    context "when backtrace is a heterogeneous language stack trace" do
      let(:exception) do
        double(:Exception, :backtrace => [
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
      let(:exception) { double(:Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

      it "is handled gracefully" do
        safely do
          expect { notification.send(:read_failed_line) }.not_to raise_error
        end
      end
    end

    context "when ruby reports a bogus line number in the stack trace" do
      let(:exception) { double(:Exception, :backtrace => [ "#{__FILE__}:10000000"]) }

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

      let(:exception) { double(:Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

      it "doesn't hang when file exists" do
        expect(notification.send(:read_failed_line).strip).to eql(
          %Q[let(:exception) { double(:Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"]) }])
      end

    end
  end
end
