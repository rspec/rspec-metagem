require 'spec_helper'
require 'rspec/core/formatters/terminal_color'

describe RSpec::Core::Formatters::TerminalColor do
  it "accepts a VT100 integer code and formats the text with it" do
     RSpec::Core::Formatters::TerminalColor.colorize('abc', 32).should == "\e[32mabc\e[0m"
  end
  
  it "accepts a symbol as a color parameter and translates it to the correct integer code, then formats the text with it" do
     RSpec::Core::Formatters::TerminalColor.colorize('abc', :green).should == "\e[32mabc\e[0m"
  end
  
  it "accepts a non-default color symbol as a parameter and translates it to the correct integer code, then formats the text with it" do
     RSpec::Core::Formatters::TerminalColor.colorize('abc', :cyan).should == "\e[36mabc\e[0m"
  end
end