require 'spec_helper'

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

end

