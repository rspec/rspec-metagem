require "spec_helper"
require 'rspec/core/drb'

RSpec.describe "::DRbCommandLine", :type => :drb, :unless => RUBY_PLATFORM == 'java' do
  let(:config) { RSpec::Core::Configuration.new }
  let(:out)    { StringIO.new }
  let(:err)    { StringIO.new }

  include_context "spec files"

  def command_line(*args)
    RSpec::Core::DRbCommandLine.new(config_options(*args))
  end

  def config_options(*args)
    RSpec::Core::ConfigurationOptions.new(args)
  end

  context "without server running" do
    it "raises an error" do
      expect { command_line.run(err, out) }.to raise_error(DRb::DRbConnError)
    end

    after { DRb.stop_service }
  end

  describe "--drb-port" do
    def with_RSPEC_DRB_set_to(val)
      with_env_vars('RSPEC_DRB' => val) { yield }
    end

    context "without RSPEC_DRB environment variable set" do
      it "defaults to 8989" do
        with_RSPEC_DRB_set_to(nil) do
          expect(command_line.drb_port).to eq(8989)
        end
      end

      it "sets the DRb port" do
        with_RSPEC_DRB_set_to(nil) do
          expect(command_line("--drb-port", "1234").drb_port).to eq(1234)
          expect(command_line("--drb-port", "5678").drb_port).to eq(5678)
        end
      end
    end

    context "with RSPEC_DRB environment variable set" do
      context "without config variable set" do
        it "uses RSPEC_DRB value" do
          with_RSPEC_DRB_set_to('9000') do
            expect(command_line.drb_port).to eq("9000")
          end
        end
      end

      context "and config variable set" do
        it "uses configured value" do
          with_RSPEC_DRB_set_to('9000') do
            expect(command_line(*%w[--drb-port 5678]).drb_port).to eq(5678)
          end
        end
      end
    end
  end

  context "with server running", :slow do
    class SimpleDRbSpecServer
      def self.run(argv, err, out)
        options = RSpec::Core::ConfigurationOptions.new(argv)
        config = RSpec::Core::Configuration.new
        RSpec::Core::CommandLine.new(options, config).run(err, out)
      end
    end

    before(:all) do
      @drb_port = '8990'
      @drb_example_file_counter = 0
      DRb::start_service("druby://127.0.0.1:#{@drb_port}", SimpleDRbSpecServer)
    end

    after(:all) do
      DRb::stop_service
    end

    it "returns 0 if spec passes" do
      result = command_line("--drb-port", @drb_port, passing_spec_filename).run(err, out)
      expect(result).to be(0)
    end

    it "returns 1 if spec fails" do
      result = command_line("--drb-port", @drb_port, failing_spec_filename).run(err, out)
      expect(result).to be(1)
    end

    it "outputs colorized text when running with --colour option" do
      pending "figure out a way to tell the output to say it's tty"
      command_line(failing_spec_filename, "--color", "--drb-port", @drb_port).run(err, out)
      out.rewind
      expect(out.read).to match(/\e\[31m/m)
    end
  end
end

RSpec.describe RSpec::Core::DrbOptions, :isolated_directory => true, :isolated_home => true do
  include ConfigOptionsHelper

  describe "#drb_argv" do
    it "preserves extra arguments" do
      allow(File).to receive(:exist?) { false }
      expect(config_options_object(*%w[ a --drb b --color c ]).drb_argv).to match_array %w[ --color a b c ]
    end

    %w(--color --fail-fast --profile --backtrace --tty).each do |option|
      it "includes #{option}" do
        expect(config_options_object("#{option}").drb_argv).to include("#{option}")
      end
    end

    it "includes --failure-exit-code" do
      expect(config_options_object(*%w[--failure-exit-code 2]).drb_argv).to include("--failure-exit-code", "2")
    end

    it "includes --options" do
      expect(config_options_object(*%w[--options custom.opts]).drb_argv).to include("--options", "custom.opts")
    end

    it "includes --order" do
      expect(config_options_object(*%w[--order random]).drb_argv).to include('--order', 'random')
    end

    context "with --example" do
      it "includes --example" do
        expect(config_options_object(*%w[--example foo]).drb_argv).to include("--example", "foo")
      end

      it "unescapes characters which were escaped upon storing --example originally" do
        expect(config_options_object("--example", "foo\\ bar").drb_argv).to include("--example", "foo bar")
      end
    end

    context "with tags" do
      it "includes the inclusion tags" do
        coo = config_options_object("--tag", "tag")
        expect(coo.drb_argv).to eq(["--tag", "tag"])
      end

      it "includes the inclusion tags with values" do
        coo = config_options_object("--tag", "tag:foo")
        expect(coo.drb_argv).to eq(["--tag", "tag:foo"])
      end

      it "leaves inclusion tags intact" do
        coo = config_options_object("--tag", "tag")
        coo.drb_argv
        rules = coo.filter_manager.inclusions.rules
        expect(rules).to eq( {:tag=>true} )
      end

      it "leaves inclusion tags with values intact" do
        coo = config_options_object("--tag", "tag:foo")
        coo.drb_argv
        rules = coo.filter_manager.inclusions.rules
        expect(rules).to eq( {:tag=>'foo'} )
      end

      it "includes the exclusion tags" do
        coo = config_options_object("--tag", "~tag")
        expect(coo.drb_argv).to eq(["--tag", "~tag"])
      end

      it "includes the exclusion tags with values" do
        coo = config_options_object("--tag", "~tag:foo")
        expect(coo.drb_argv).to eq(["--tag", "~tag:foo"])
      end

      it "leaves exclusion tags intact" do
        coo = config_options_object("--tag", "~tag")
        coo.drb_argv
        rules = coo.filter_manager.exclusions.rules
        expect(rules).to eq( {:tag => true} )
      end

      it "leaves exclusion tags with values intact" do
        coo = config_options_object("--tag", "~tag:foo")
        coo.drb_argv
        rules = coo.filter_manager.exclusions.rules
        expect(rules).to eq( {:tag => 'foo'} )
      end
    end

    context "with formatters" do
      it "includes the formatters" do
        coo = config_options_object("--format", "d")
        expect(coo.drb_argv).to eq(["--format", "d"])
      end

      it "leaves formatters intact" do
        coo = config_options_object("--format", "d")
        coo.drb_argv
        expect(coo.options[:formatters]).to eq([["d"]])
      end

      it "leaves output intact" do
        coo = config_options_object("--format", "p", "--out", "foo.txt", "--format", "d")
        coo.drb_argv
        expect(coo.options[:formatters]).to eq([["p","foo.txt"],["d"]])
      end
    end

    context "with --out" do
      it "combines with formatters" do
        coo = config_options_object(*%w[--format h --out report.html])
        expect(coo.drb_argv).to       eq(%w[--format h --out report.html])
      end
    end

    context "with -I libs" do
      it "includes -I" do
        expect(config_options_object(*%w[-I a_dir]).drb_argv).to eq(%w[-I a_dir])
      end

      it "includes multiple paths" do
        expect(config_options_object(*%w[-I dir_1 -I dir_2 -I dir_3]).drb_argv).to eq(
                               %w[-I dir_1 -I dir_2 -I dir_3]
        )
      end
    end

    context "with --require" do
      it "includes --require" do
        expect(config_options_object(*%w[--require a_path]).drb_argv).to eq(%w[--require a_path])
      end

      it "includes multiple paths" do
        expect(config_options_object(*%w[--require dir/ --require file.rb]).drb_argv).to eq(
                               %w[--require dir/ --require file.rb]
        )
      end
    end

    context "--drb specified in ARGV" do
      it "renders all the original arguments except --drb" do
        drb_argv = config_options_object(*%w[ --drb --color --format s --example pattern
                                              --profile --backtrace -I
                                              path/a -I path/b --require path/c --require
                                              path/d]).drb_argv
        expect(drb_argv).to eq(%w[ --color --profile --backtrace --example pattern --format s -I path/a -I path/b --require path/c --require path/d])
      end
    end

    context "--drb specified in the options file" do
      it "renders all the original arguments except --drb" do
        File.open("./.rspec", "w") {|f| f << "--drb --color"}
        drb_argv = config_options_object(*%w[ --tty --format s --example
                                         pattern --profile --backtrace ]).drb_argv

        expect(drb_argv).to eq(%w[ --color --profile --backtrace --tty
                               --example pattern --format s])
      end
    end

    context "--drb specified in ARGV and the options file" do
      it "renders all the original arguments except --drb" do
        File.open("./.rspec", "w") {|f| f << "--drb --color"}
        drb_argv = config_options_object(*%w[ --drb --format s --example
                                         pattern --profile --backtrace]).drb_argv

        expect(drb_argv).to eq(%w[ --color --profile --backtrace --example pattern --format s])
      end
    end

    context "--drb specified in ARGV and in as ARGV-specified --options file" do
      it "renders all the original arguments except --drb and --options" do
        File.open("./.rspec", "w") {|f| f << "--drb --color"}
        drb_argv = config_options_object(*%w[ --drb --format s --example
                                         pattern --profile --backtrace]).drb_argv

        expect(drb_argv).to eq(%w[ --color --profile --backtrace --example pattern --format s ])
      end
    end
  end
end
