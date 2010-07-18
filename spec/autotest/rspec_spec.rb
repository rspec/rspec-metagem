require "spec_helper"

describe Autotest::Rspec2 do
  describe "commands" do
    before(:each) do
      @rspec_autotest = Autotest::Rspec2.new
      @rspec_autotest.stub!(:ruby).and_return "ruby"

      @ruby = @rspec_autotest.ruby
      @spec_cmd = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'rspec'))
      files = %w[file_one file_two]
      @files_to_test = {
        files[0] => [],
        files[1] => []
      }
      # this is not the inner representation of Autotest!
      @rspec_autotest.files_to_test = @files_to_test
      @to_test = files.map { |f| File.expand_path(f) }.join ' '
    end

    it "should make the appropriate test command" do
      actual = @rspec_autotest.make_test_cmd(@files_to_test)
      expected = /#{@ruby}.*#{@spec_cmd} (.*)/

      actual.should match(expected)

      actual =~ expected
      $1.should =~ /#{File.expand_path('file_one')}/
      $1.should =~ /#{File.expand_path('file_two')}/
    end

    it "should return a blank command for no files" do
      @rspec_autotest.make_test_cmd({}).should == ''
    end
  end

  describe "mappings" do

    before(:each) do
      @lib_file = "lib/something.rb"
      @spec_file = "spec/something_spec.rb"
      @rspec_autotest = Autotest::Rspec2.new
      @rspec_autotest.hook :initialize
    end

    it "should find the spec file for a given lib file" do
      @rspec_autotest.should map_specs([@spec_file]).to(@lib_file)
    end

    it "should find the spec file if given a spec file" do
      @rspec_autotest.should map_specs([@spec_file]).to(@spec_file)
    end

    it "should ignore files in spec dir that aren't specs" do
      @rspec_autotest.should map_specs([]).to("spec/spec_helper.rb")
    end

    it "should ignore untracked files (in @file)"  do
      @rspec_autotest.should map_specs([]).to("lib/untracked_file")
    end
  end

  describe "consolidating failures" do
    before(:each) do
      @rspec_autotest = Autotest::Rspec2.new

      @spec_file = "spec/autotest/some_spec.rb"
      @rspec_autotest.instance_variable_set("@files", {@spec_file => Time.now})
      @rspec_autotest.stub!(:find_files_to_test).and_return true
    end

    it "should return no failures if no failures were given in the output" do
      @rspec_autotest.consolidate_failures([[]]).should == {}
    end

    it "should return a hash with the spec filename => spec name for each failure or error" do
      @rspec_autotest.stub!(:test_files_for).and_return "spec/autotest/some_spec.rb"
      failures = [
        [
          "false should be false",
          "expected: true,\n     got: false (using ==)\n#{@spec_file}:203:"
        ]
      ]
      @rspec_autotest.consolidate_failures(failures).should == {
        @spec_file => ["false should be false"]
      }
    end

    it "should not include the subject file" do
      subject_file = "lib/autotest/some.rb"
      @rspec_autotest.stub!(:test_files_for).and_return "spec/autotest/some_spec.rb"
      failures = [
        [
          "false should be false",
          "expected: true,\n     got: false (using ==)\n#{subject_file}:143:\n#{@spec_file}:203:"
        ]
      ]
      @rspec_autotest.consolidate_failures(failures).keys.should_not include(subject_file)
    end
  end

  describe "normalizing file names" do
    it "should ensure that a single file appears in files_to_test only once" do
      @rspec_autotest = Autotest::Rspec2.new
      @files_to_test = {}
      ['filename.rb', './filename.rb', File.expand_path('filename.rb')].each do |file|
        @files_to_test[file] = []
      end
      @rspec_autotest.normalize(@files_to_test).should have(1).file
    end
  end
end
