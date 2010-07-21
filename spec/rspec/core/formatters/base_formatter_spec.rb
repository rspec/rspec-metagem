require "spec_helper"

describe RSpec::Core::Formatters::BaseFormatter do

  let(:output)    { StringIO.new }
  let(:formatter) { RSpec::Core::Formatters::BaseFormatter.new(output) }

  it "has start as an interface with one argument" do
    formatter.should have_interface_for(:start).with(1).argument
  end

  it "has example_group_started as an interface with one argument" do
    formatter.should have_interface_for(:example_group_started).with(1).argument
  end

  it "has example_passed as an interface with one argument" do
    formatter.should have_interface_for(:example_passed).with(1).arguments
  end

  it "has example_pending as an interface with one argument" do
    formatter.should have_interface_for(:example_pending).with(1).arguments
  end

  it "has example_failed as an interface with one argument" do
    formatter.should have_interface_for(:example_failed).with(1).arguments
  end

  it "has start_dump as an interface with no arguments" do
    formatter.should have_interface_for(:start_dump).with(0).arguments
  end

  it "has dump_failures as an interface with no arguments" do
    formatter.should have_interface_for(:dump_failures).with(0).arguments
  end

  it "has dump_summary as an interface with zero arguments" do
    formatter.should have_interface_for(:dump_summary).with(0).arguments
  end

  it "has dump_pending as an interface with zero arguments" do
    formatter.should have_interface_for(:dump_pending).with(0).arguments
  end

  it "has close as an interface with zero arguments" do
    formatter.should have_interface_for(:close).with(0).arguments
  end

  describe '#format_backtrace' do
    it "displays the full backtrace when the example is given the :full_backtrace => true option", :full_backtrace => true
  end

  describe "backtrace_line" do
    it "trims current working directory" do
      formatter.__send__(:backtrace_line, File.expand_path(__FILE__)).should == "./spec/rspec/core/formatters/base_formatter_spec.rb"
    end
  end

end
