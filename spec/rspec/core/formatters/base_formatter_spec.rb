require "spec_helper"

describe RSpec::Core::Formatters::BaseFormatter do

  let(:output)    { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseFormatter.new(output) }

  describe "backtrace_line" do
    it "trims current working directory" do
      formatter.__send__(:backtrace_line, File.expand_path(__FILE__)).should == "./spec/rspec/core/formatters/base_formatter_spec.rb"
    end
  end

end
