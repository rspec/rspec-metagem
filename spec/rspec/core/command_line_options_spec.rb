require 'spec_helper'
require 'ostruct'

describe Rspec::Core::CommandLineOptions do
  
  def options_from_args(*args)
    Rspec::Core::CommandLineOptions.new(args).parse.options
  end

  describe 'color_enabled' do
    example "-c, --colour, or --color should be parsed as true" do
      options_from_args('-c').should include(:color_enabled => true)
      options_from_args('--color').should include(:color_enabled => true)
      options_from_args('--colour').should include(:color_enabled => true)
    end

    example "--no-color should be parsed as false" do
      options_from_args('--no-color').should include(:color_enabled => false)
    end
  end

  describe  'formatter' do
    example '-f or --formatter with no arguments should be parsed as nil' do
      options_from_args('--formatter').should include(:formatter => nil)
    end

    example '-f or --formatter with an argument should parse' do
      options_from_args('--formatter', 'd').should include(:formatter => 'd')
      options_from_args('-f', 'd').should include(:formatter => 'd')
      options_from_args('-fd').should include(:formatter => 'd')
    end
  end

  describe 'profile_examples' do
    example "-p or --profile should be parsed as true" do
      options_from_args('-p').should include(:profile_examples => true)
      options_from_args('--profile').should include(:profile_examples => true)
    end
  end

  describe 'line_number' do
    it "is parsed from -l or --line_number" do
      options_from_args('-l','3').should include(:line_number => '3')
      options_from_args('--line_number','3').should include(:line_number => '3')
    end
  end

  describe "example" do
    it "is parsed from --example or -e" do
      options_from_args('--example','foo').should include(:full_description => /foo/)
      options_from_args('-e','bar').should include(:full_description => /bar/)
    end
  end

  describe "options" do
    it "is parsed from --options or -o" do
      options_from_args('--options', 'spec/spec.opts').should include(:options_file => "spec/spec.opts")
      options_from_args('-o', 'foo/spec.opts').should include(:options_file => "foo/spec.opts")
    end

    it "defaults to spec/spec.opts when you don't give it a file path" do
      options_from_args('-o').should include(:options_file => "spec/spec.opts")
      options_from_args('--options').should include(:options_file => "spec/spec.opts")
    end
    
    it "merges options from the CLI and file options gracefully" do
      cli_options = Rspec::Core::CommandLineOptions.new(['--formatter', 'progress', '--options', 'spec/spec.opts']).parse
      cli_options.stub!(:parse_spec_file_contents).and_return(:full_backtrace => true)
      config = OpenStruct.new
      cli_options.apply(config)
      config.full_backtrace.should == true
      config.formatter.should == 'progress'
    end

    it "CLI options trump file options" do
      cli_options = Rspec::Core::CommandLineOptions.new(['--formatter', 'progress', '--options', 'spec/spec.opts']).parse
      cli_options.stub!(:parse_spec_file_contents).and_return(:formatter => 'documentation')
      config = OpenStruct.new
      cli_options.apply(config)
      config.formatter.should == 'progress'
    end
  end

  describe "files_or_directories_to_run" do
    it "parses files from '-c file.rb dir/file.rb'" do
      options_from_args("-c", "file.rb", "dir/file.rb").should include(:files_or_directories_to_run => ["file.rb", "dir/file.rb"])
    end

    it "parses dir from 'dir'" do
      options_from_args("dir").should include(:files_or_directories_to_run => ["dir"])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      options_from_args("dir", "spec/file1_spec.rb", "spec/file2_spec.rb").should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])
    end

  end

  describe "--backtrace (-b)" do
    it "sets full_backtrace on config" do
      options_from_args("--backtrace").should include(:full_backtrace => true)
      options_from_args("-b").should include(:full_backtrace => true)
    end
  end

end

