require "spec_helper"


describe "::DRbProxy" do
  before do
    RSpec.stub(:configuration).and_return(RSpec::Core::Configuration.new)
  end

  context "without server running" do
    it "prints error" do
      err, out = StringIO.new, StringIO.new
      RSpec::Core::Runner::DRbProxy.new(:argv => [], :remote_port => 1234).run(err, out)

      err.rewind
      err.read.should =~ /No DRb server is running/
    end
    
    it "returns false" do
      err, out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner::DRbProxy.new(:argv => [], :remote_port => 1234).run(err, out)
      result.should be_false
    end
  end
  
  context "with server running" do
    class ::FakeDrbSpecServer
      def self.run(argv, err, out)
        RSpec::Core::Runner.new.run(argv, err, out)
      end
    end

    def dummy_spec_filename
      File.expand_path(File.dirname(__FILE__)) + "/_dummy_spec.rb"
    end
  
    before(:all) do
      @drb_port = "8999"
      create_dummy_spec_file
      DRb::DRbServer.new("druby://127.0.0.1:#{@drb_port}", ::FakeDrbSpecServer)
    end

    after(:all) do
      File.delete(dummy_spec_filename)
      DRb.stop_service
    end
  
    def create_dummy_spec_file
      File.open(dummy_spec_filename, 'w') do |f|
        f.write %{
          describe "DUMMY CONTEXT for 'DrbCommandLine with -c option'" do
            it "should be output with green bar" do
              true.should be_true
            end
  
            it "should be output with red bar" do
              fail "I want to see a red bar!"
            end
          end
        }
      end
    end
  
    def run_spec_via_druby(argv)
      err, out = StringIO.new, StringIO.new
      RSpec::Core::Runner::DRbProxy.new(:argv => argv, :remote_port => @drb_port).run(err, out)
      out.rewind
      out.read
    end
    
    it "returns true" do
      err = out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner::DRbProxy.new(:argv => [] , :remote_port => @drb_port).run(err, out)
      result.should be_true
    end
  
    it "should run against local server" do
      out = run_spec_via_druby(['--version'])
      out.should =~ /rspec \d+\.\d+\.\d+.*/m
    end
  
    it "should output green colorized text when running with --colour option" do
      out = run_spec_via_druby(["--colour", dummy_spec_filename])
      out.should =~ /\e\[32m/m
    end
  
    it "should output red colorized text when running with -c option" do
      out = run_spec_via_druby(["-c", dummy_spec_filename])
      out.should =~ /\e\[31m/m
    end
    
    it "integrates via #run" do
      err, out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner.new.run(%W[ --drb --drb-port #{@drb_port} --version ], err, out)
      result.should be_true
    end
  end
  
end
