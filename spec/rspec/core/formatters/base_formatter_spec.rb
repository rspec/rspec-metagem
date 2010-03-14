require "spec_helper"

describe Rspec::Core::Formatters::BaseFormatter do
  
  let(:formatter) { Rspec::Core::Formatters::BaseFormatter.new }

  it "has start as an interface with one argument" do
    formatter.should have_interface_for(:start).with(1).argument
  end

  it "has add_example_group as an interface with one argument" do
    formatter.should have_interface_for(:add_example_group).with(1).argument
  end

  it "has example_finished as an interface with one argument" do
    formatter.should have_interface_for(:example_finished).with(1).arguments
  end

  it "has start_dump as an interface with 1 arguments" do
    formatter.should have_interface_for(:start_dump).with(1).arguments
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
  
end
