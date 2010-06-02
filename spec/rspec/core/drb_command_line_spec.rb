require "spec_helper"

describe "::DRbCommandLine" do
  before do
    RSpec.stub(:configuration).and_return(RSpec::Core::Configuration.new)
  end

  context "without server running" do
    it "prints error" do
      err = out = StringIO.new
      RSpec::Core::DRbCommandLine.new([]).run(err, out)

      err.rewind
      err.read.should =~ /No DRb server is running/
    end
    
    it "returns false" do
      err = out = StringIO.new
      result = RSpec::Core::DRbCommandLine.new([]).run(err, out)
      result.should be_false
    end
  end
  
  describe "--drb-port" do
    def config_options_object(*args)
      RSpec::Core::DRbCommandLine.new(args)
    end

    def with_RSPEC_DRB_set_to(val)
      original = ENV['RSPEC_DRB']
      ENV['RSPEC_DRB'] = val
      begin
        yield
      ensure
        ENV['RSPEC_DRB'] = original
      end
    end

    context "without RSPEC_DRB environment variable set" do
      it "defaults to 8989" do
        with_RSPEC_DRB_set_to(nil) do
          RSpec::Core::DRbCommandLine.new([]).drb_port.should == 8989
        end
      end
      
      it "sets the DRb port" do
        with_RSPEC_DRB_set_to(nil) do
          RSpec::Core::DRbCommandLine.new(["--drb-port", "1234"]).drb_port.should == 1234
          RSpec::Core::DRbCommandLine.new(["--drb-port", "5678"]).drb_port.should == 5678
        end
      end
    end

    context "with RSPEC_DRB environment variable set" do

      context "without config variable set" do
        it "uses RSPEC_DRB value" do
          with_RSPEC_DRB_set_to('9000') do
            RSpec::Core::DRbCommandLine.new([]).drb_port.should == "9000"
          end
        end
      end
        
      context "and config variable set" do
        it "uses configured value" do
          with_RSPEC_DRB_set_to('9000') do
            RSpec::Core::DRbCommandLine.new(%w[--drb-port 5678]).drb_port.should == 5678
          end
        end
      end
    end

  end
  # context "with server running" do
    # class ::FakeDrbSpecServer
      # def self.run(argv, err, out) 
        # RSpec::Core::CommandLine.new(argv).run(err, out)
      # end
    # end

    # def dummy_spec_filename
      # @dummy_spec_filename ||= File.expand_path(File.dirname(__FILE__)) + "/_dummy_spec#{@drb_example_file_counter}.rb"
    # end
  
    # before(:all) do
      # @drb_port = 8990
      # @drb_example_file_counter = 0
      # DRb::start_service("druby://127.0.0.1:#{@drb_port}", ::FakeDrbSpecServer)
    # end

    # before(:each) do
      # @drb_example_file_counter += 1
      # create_dummy_spec_file
    # end

    # after(:each) do
      # File.delete(dummy_spec_filename)
    # end

    # after(:all) do
      # DRb::stop_service
    # end

    # def create_dummy_spec_file
      # File.open(dummy_spec_filename, 'w') do |f|
        # f.write %q{
          # p __FILE__
          # describe "DUMMY CONTEXT for 'DrbCommandLine with -c option'" do
            # it "should be output with green bar" do
              # true.should be_true
            # end

            # it "should be output with red bar" do
              # raise("I want to see a red bar!")
            # end
          # end
        # }
      # end
    # end

    # def run_spec_via_druby(argv)
      # err, out = StringIO.new, StringIO.new
      # RSpec::Core::DRbCommandLine.new(argv.push("--drb-port", @drb_port.to_s)).run(err, out)
      # out.rewind
      # out.read
    # end

    # it "returns true" do
      # err, out = StringIO.new, StringIO.new
      # result = RSpec::Core::DRbCommandLine.new(["--drb-port", @drb_port.to_s]).run(err, out)
      # result.should be_true
    # end
    
    # it "should output green colorized text when running with --colour option" do
      # out = run_spec_via_druby(["--colour", dummy_spec_filename])
      # out.should =~ /\e\[32m/m
    # end
  
    # it "should output red colorized text when running with -c option" do
      # out = run_spec_via_druby(["-c", dummy_spec_filename])
      # out.should =~ /\e\[31m/m
    # end
    
    # it "integrates via Runner.new.run" do
      # err, out = StringIO.new, StringIO.new
      # result = RSpec::Core::Runner.new.run(%W[ --drb --drb-port #{@drb_port} #{dummy_spec_filename}], err, out)
      # result.should be_true
    # end
  # end
  
end
