require 'spec_helper'
require 'rspec/core/formatters/base_formatter'

RSpec.describe RSpec::Core::Formatters::BaseFormatter do
  include FormatterSupport

  describe "read_failed_line" do
    it "deals gracefully with a heterogeneous language stack trace" do
      exception = double(:Exception, :backtrace => [
        "at Object.prototypeMethod (foo:331:18)",
        "at Array.forEach (native)",
        "at a_named_javascript_function (/some/javascript/file.js:39:5)",
        "/some/line/of/ruby.rb:14"
      ])
      example = double(:Example, :file_path => __FILE__)
      expect {
        formatter.send(:read_failed_line, exception, example)
      }.not_to raise_error
    end

    it "deals gracefully with a security error" do
      exception = double(:Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"])
      example = double(:Example, :file_path => __FILE__)
      safely do
        expect {
          formatter.send(:read_failed_line, exception, example)
        }.not_to raise_error
      end
    end

    context "when ruby reports a bogus line number in the stack trace" do
      it "reports the filename and that it was unable to find the matching line" do
        exception = double(:Exception, :backtrace => [ "#{__FILE__}:10000000" ])
        example = double(:Example, :file_path => __FILE__)

        msg = formatter.send(:read_failed_line, exception, example)
        expect(msg).to include("Unable to find matching line")
      end
    end

    context "when String alias to_int to_i" do
      before do
        String.class_eval do
          alias :to_int :to_i
        end
      end

      after do
        String.class_eval do
          undef to_int
        end
      end

      it "doesn't hang when file exists" do
        exception = double(:Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"])

        example = double(:Example, :file_path => __FILE__)
        expect(formatter.send(:read_failed_line, exception, example)).to eql(
          %Q{        exception = double(:Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"])\n})
      end

    end
  end
end
