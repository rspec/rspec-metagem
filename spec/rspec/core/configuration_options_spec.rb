require 'spec_helper'
require 'ostruct'

describe RSpec::Core::ConfigurationOptions do
  include ConfigOptionsHelper

  it "warns when HOME env var is not set", :unless => (RUBY_PLATFORM == 'java') do
    begin
      orig_home = ENV.delete("HOME")
      coo = RSpec::Core::ConfigurationOptions.new([])
      coo.should_receive(:warn)
      coo.parse_options
    ensure
      ENV["HOME"] = orig_home
    end
  end

  describe "#configure" do
    it "sends libs before requires" do
      opts = config_options_object(*%w[--require a/path -I a/lib])
      config = double("config").as_null_object
      config.should_receive(:libs=).ordered
      config.should_receive(:requires=).ordered
      opts.configure(config)
    end

    it "sends requires before formatter" do
      opts = config_options_object(*%w[--require a/path -f a/formatter])
      config = double("config").as_null_object
      config.should_receive(:requires=).ordered
      config.should_receive(:add_formatter).ordered
      opts.configure(config)
    end

    it "sends default_path before files_or_directories_to_run" do
      opts = config_options_object(*%w[--default_path spec])
      config = double("config").as_null_object
      config.should_receive(:default_path=).ordered
      config.should_receive(:files_or_directories_to_run=).ordered
      opts.configure(config)
    end

    it "sends pattern before files_or_directories_to_run" do
      opts = config_options_object(*%w[--pattern **/*.spec])
      config = double("config").as_null_object
      config.should_receive(:pattern=).ordered
      config.should_receive(:files_or_directories_to_run=).ordered
      opts.configure(config)
    end

    it "merges the :exclusion_filter option with the default exclusion_filter" do
      opts = config_options_object(*%w[--tag ~slow])
      config = RSpec::Core::Configuration.new
      opts.configure(config)
      config.exclusion_filter.should have_key(:slow)
    end

    it "forces color_enabled" do
      opts = config_options_object(*%w[--color])
      config = RSpec::Core::Configuration.new
      config.should_receive(:force).with(:color => true)
      opts.configure(config)
    end

    it "forces inclusion_filter" do
      opts = config_options_object(*%w[--tag foo:bar])
      config = RSpec::Core::Configuration.new
      config.should_receive(:force).with(:inclusion_filter => {:foo => 'bar'})
      opts.configure(config)
    end

    it "forces exclusion_filter" do
      opts = config_options_object(*%w[--tag ~foo:bar])
      config = RSpec::Core::Configuration.new
      config.should_receive(:force).with(:exclusion_filter => {:foo => 'bar'})
      opts.configure(config)
    end
  end

  describe "-c, --color, and --colour" do
    it "sets :color => true" do
      parse_options('-c').should include(:color => true)
      parse_options('--color').should include(:color => true)
      parse_options('--colour').should include(:color => true)
    end
  end

  describe "--no-color" do
    it "sets :color => false" do
      parse_options('--no-color').should include(:color => false)
    end

    it "overrides previous :color => true" do
      parse_options('--color', '--no-color').should include(:color => false)
    end

    it "gets overriden by a subsequent :color => true" do
      parse_options('--no-color', '--color').should include(:color => true)
    end
  end

  describe "-I" do
    example "adds to :libs" do
      parse_options('-I', 'a_dir').should include(:libs => ['a_dir'])
    end
    example "can be used more than once" do
      parse_options('-I', 'dir_1', '-I', 'dir_2').should include(:libs => ['dir_1','dir_2'])
    end
  end

  describe '--require' do
    example "requires files" do
      parse_options('--require', 'a/path').should include(:requires => ['a/path'])
    end
    example "can be used more than once" do
      parse_options('--require', 'path/1', '--require', 'path/2').should include(:requires => ['path/1','path/2'])
    end
  end

  describe "--format, -f" do
    it "sets :formatter" do
      parse_options('--format', 'd').should include(:formatters => [['d']])
      parse_options('-f', 'd').should include(:formatters => [['d']])
      parse_options('-fd').should include(:formatters => [['d']])
    end

    example "can accept a class name" do
      parse_options('-fSome::Formatter::Class').should include(:formatters => [['Some::Formatter::Class']])
    end
  end

  describe "--profile, -p" do
    it "sets :profile_examples => true" do
      parse_options('-p').should include(:profile_examples => true)
      parse_options('--profile').should include(:profile_examples => true)
    end
  end

  describe '--line_number' do
    it "sets :line_number" do
      parse_options('-l','3').should include(:line_numbers => ['3'])
      parse_options('--line_number','3').should include(:line_numbers => ['3'])
    end

    it "can be specified multiple times" do
      parse_options('-l','3', '-l', '6').should include(:line_numbers => ['3', '6'])
      parse_options('--line_number','3', '--line_number', '6').should include(:line_numbers => ['3', '6'])
    end
  end

  describe "--example" do
    it "sets :full_description" do
      parse_options('--example','foo').should include(:full_description => /foo/)
      parse_options('-e','bar').should include(:full_description => /bar/)
    end
  end

  describe "--backtrace, -b" do
    it "sets full_backtrace on config" do
      parse_options("--backtrace").should include(:full_backtrace => true)
      parse_options("-b").should include(:full_backtrace => true)
    end
  end

  describe "--debug, -d" do
    it "sets :debug => true" do
      parse_options("--debug").should include(:debug => true)
      parse_options("-d").should include(:debug => true)
    end
  end

  describe "--fail-fast" do
    it "defaults to false" do
      parse_options[:fail_fast].should be_false
    end

    it "sets fail_fast on config" do
      parse_options("--fail-fast")[:fail_fast].should be_true
    end
  end

  describe "--failure-exit-code" do
    it "sets :failure_exit_code" do
      parse_options('--failure-exit-code', '0').should include(:failure_exit_code => 0)
      parse_options('--failure-exit-code', '1').should include(:failure_exit_code => 1)
      parse_options('--failure-exit-code', '2').should include(:failure_exit_code => 2)
    end

    it "overrides previous :failure_exit_code" do
      parse_options('--failure-exit-code', '2', '--failure-exit-code', '3').should include(:failure_exit_code => 3)
    end
  end

  describe "--options" do
    it "sets :custom_options_file" do
      parse_options(*%w[-O my.opts]).should include(:custom_options_file => "my.opts")
      parse_options(*%w[--options my.opts]).should include(:custom_options_file => "my.opts")
    end
  end

  describe "--drb, -X" do
    context "combined with --debug" do
      it "turns off the debugger if --drb is specified first" do
        config_options_object("--drb", "--debug").drb_argv.should_not include("--debug")
        config_options_object("--drb", "-d"     ).drb_argv.should_not include("--debug")
        config_options_object("-X",    "--debug").drb_argv.should_not include("--debug")
        config_options_object("-X",    "-d"     ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --drb is specified later" do
        config_options_object("--debug", "--drb").drb_argv.should_not include("--debug")
        config_options_object("-d",      "--drb").drb_argv.should_not include("--debug")
        config_options_object("--debug", "-X"   ).drb_argv.should_not include("--debug")
        config_options_object("-d",      "-X"   ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --drb is specified in the options file" do
        File.open("./.rspec", "w") {|f| f << "--drb"}
        config_options_object("--debug").drb_argv.should_not include("--debug")
        config_options_object("-d"     ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --debug is specified in the options file" do
        File.open("./.rspec", "w") {|f| f << "--debug"}
        config_options_object("--drb").drb_argv.should_not include("--debug")
        config_options_object("-X"   ).drb_argv.should_not include("--debug")
      end
    end

    it "does not send --drb back to the parser after parsing options" do
      config_options_object("--drb", "--color").drb_argv.should_not include("--drb")
    end

  end

  describe "--no-drb" do
    it "disables drb" do
      parse_options("--no-drb").should include(:drb => false)
    end

    it "overrides a previous drb => true" do
      parse_options("--drb", "--no-drb").should include(:drb => false)
    end

    it "gets overriden by a subsquent drb => true" do
      parse_options("--no-drb", "--drb").should include(:drb => true)
    end
  end


  describe "files_or_directories_to_run" do
    it "parses files from '-c file.rb dir/file.rb'" do
      parse_options("-c", "file.rb", "dir/file.rb").should include(:files_or_directories_to_run => ["file.rb", "dir/file.rb"])
    end

    it "parses dir from 'dir'" do
      parse_options("dir").should include(:files_or_directories_to_run => ["dir"])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      parse_options("dir", "spec/file1_spec.rb", "spec/file2_spec.rb").should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])
    end

    it "provides no files or directories if spec directory does not exist" do
      FileTest.stub(:directory?).with("spec").and_return false
      parse_options().should include(:files_or_directories_to_run => [])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      parse_options("dir", "spec/file1_spec.rb", "spec/file2_spec.rb").should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])
    end
  end

  describe "default_path" do
    it "gets set before files_or_directories_to_run" do
      config = double("config").as_null_object
      config.should_receive(:default_path=).ordered
      config.should_receive(:files_or_directories_to_run=).ordered
      opts = config_options_object("--default_path", "foo")
      opts.configure(config)
    end
  end

  describe "sources: ~/.rspec, ./.rspec, custom, CLI, and SPEC_OPTS" do
    it "merges global, local, SPEC_OPTS, and CLI" do
      File.open("./.rspec", "w") {|f| f << "--line 37"}
      File.open("~/.rspec", "w") {|f| f << "--color"}
      ENV["SPEC_OPTS"] = "--debug"
      options = parse_options("--drb")
      options[:color].should be_true
      options[:line_numbers].should eq(["37"])
      options[:debug].should be_true
      options[:drb].should be_true
    end

    it "merges positive tags" do
      pending
      File.open("./.rspec", "w") {|f| f << "--tag foo:bar"}
      parse_options("--tag", "baz:bam")[:inclusion_filter].
        should eq({:foo => 'bar', :baz => 'bam'})
    end

    it "merges negative tags" do
      pending
      File.open("./.rspec", "w") {|f| f << "--tag ~foo:bar"}
      parse_options("--tag", "~baz:bam")[:exclusion_filter].
        should eq({:foo => 'bar', :baz => 'bam'})
    end

    it "prefers SPEC_OPTS over CLI" do
      ENV["SPEC_OPTS"] = "--format spec_opts"
      parse_options("--format", "cli")[:formatters].should eq([['spec_opts']])
    end

    it "prefers CLI over file options" do
      File.open("./.rspec", "w") {|f| f << "--format local"}
      File.open("~/.rspec", "w") {|f| f << "--format global"}
      parse_options("--format", "cli")[:formatters].should eq([['cli']])
    end

    it "prefers local file options over global" do
      File.open("./.rspec", "w") {|f| f << "--format local"}
      File.open("~/.rspec", "w") {|f| f << "--format global"}
      parse_options[:formatters].should eq([['local']])
    end

    it "overwrites opposite tags according to precedence (inclusion overwrites exclusion)" do
      File.open("./.rspec", "w") {|f| f << "--tag foo"}
      File.open("~/.rspec", "w") {|f| f << "--tag ~foo"}
      parsed = parse_options
      parsed[:inclusion_filter].should eq(:foo => true)
      parsed[:exclusion_filter].should be_empty
    end

    it "does not overwrite opposite tags with different values" do
      File.open("./.rspec", "w") {|f| f << "--tag foo:baa"}
      File.open("~/.rspec", "w") {|f| f << "--tag ~foo:brr"}
      parsed = parse_options
      parsed[:inclusion_filter].should eq(:foo => 'baa')
      parsed[:exclusion_filter].should eq(:foo => 'brr')
    end

    it "overwrites opposite tags according to precedence (exclusion overwrites inclusion)" do
      File.open("./.rspec", "w") {|f| f << "--tag ~foo"}
      File.open("~/.rspec", "w") {|f| f << "--tag foo"}
      parsed = parse_options
      parsed[:inclusion_filter].should be_empty
      parsed[:exclusion_filter].should eq(:foo => true)
    end

    context "with custom options file" do
      it "ignores local and global options files" do
        File.open("./.rspec", "w") {|f| f << "--format local"}
        File.open("~/.rspec", "w") {|f| f << "--format global"}
        File.open("./custom.opts", "w") {|f| f << "--color"}
        options = parse_options("-O", "./custom.opts")
        options[:format].should be_nil
        options[:color].should be_true
      end
    end
  end
end
