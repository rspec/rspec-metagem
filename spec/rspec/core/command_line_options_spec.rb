require 'spec_helper'
require 'ostruct'

describe Rspec::Core::CommandLineOptions do
  
  def options_from_args(*args)
    Rspec::Core::CommandLineOptions.new(args).parse.options
  end

  describe 'color_enabled' do
    example "-c, --colour, or --color are parsed as true" do
      options_from_args('-c').should include(:color_enabled => true)
      options_from_args('--color').should include(:color_enabled => true)
      options_from_args('--colour').should include(:color_enabled => true)
    end

    example "--no-color is parsed as false" do
      options_from_args('--no-color').should include(:color_enabled => false)
    end
  end

  describe  'formatter' do
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

  describe "options file" do
    it "is parsed from --options or -o" do
      options_from_args("--options", "custom/path").should include(:options_file => "custom/path")
      options_from_args("-o", "custom/path").should include(:options_file => "custom/path")
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

  describe "--debug (-d)" do
    it "sets debug on config" do
      options_from_args("--debug").should include(:debug => true)
      options_from_args("-d").should include(:debug => true)
    end
  end

  describe "options file (override)" do
    let(:config) { OpenStruct.new }

    it "loads automatically" do
      File.stub(:exist?) { true }
      File.stub(:readlines) { ["--formatter", "doc"] }

      cli_options = Rspec::Core::CommandLineOptions.new([]).parse
      cli_options.apply(config)
      config.formatter.should == 'doc'
    end
    
    it "allows options on one line" do
      File.stub(:exist?) { true }
      File.stub(:readlines) { ["--formatter doc"] }

      cli_options = Rspec::Core::CommandLineOptions.new([]).parse
      cli_options.apply(config)
      config.formatter.should == 'doc'
    end
    
    it "merges options from the global and local .rspecrc and the command line" do
      File.stub(:exist?){ true }
      File.stub(:readlines) do |path|
        case path
        when ".rspecrc"
          ["--formatter", "documentation"] 
        when /\.rspecrc/
          ["--line", "37"]
        else
          raise "Unexpected path: #{path}"
        end
      end
      cli_options = Rspec::Core::CommandLineOptions.new(["--no-color"]).parse

      cli_options.apply(config)

      config.formatter.should == "documentation"
      config.line_number.should == "37"
      config.color_enabled.should be_false
    end
    
    it "prefers local options over global" do
      File.stub(:exist?){ true }
      File.stub(:readlines) do |path|
        case path
        when ".rspecrc"
          ["--formatter", "local"] 
        when /\.rspecrc/
          ["--formatter", "global"] 
        else
          raise "Unexpected path: #{path}"
        end
      end
      cli_options = Rspec::Core::CommandLineOptions.new([]).parse

      cli_options.apply(config)

      config.formatter.should == "local"
    end

    it "prefers CLI options over file options" do
      cli_options = Rspec::Core::CommandLineOptions.new(['--formatter', 'progress']).parse
      cli_options.stub!(:parse_spec_file_contents).and_return(:formatter => 'documentation')

      cli_options.apply(config)

      config.formatter.should == 'progress'
    end
  end

end

