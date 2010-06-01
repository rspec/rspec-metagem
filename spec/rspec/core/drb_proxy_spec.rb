require "spec_helper"


describe "::DRbProxy" do
  before do
    RSpec.stub(:configuration).and_return(RSpec::Core::Configuration.new)
  end

  context "without server running" do
    it "prints error" do
      err, out = StringIO.new, StringIO.new
      RSpec::Core::Runner::DRbProxy.new([]).run(err, out)

      err.rewind
      err.read.should =~ /No DRb server is running/
    end
    
    it "returns false" do
      err, out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner::DRbProxy.new([]).run(err, out)
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
      File.expand_path(File.dirname(__FILE__)) + "/resources/drb_example_spec.rb"
    end
  
    before(:all) do
      @drb_port = 8990
    end

    before(:each) do
      @drb_port += 1
      @service = DRb::start_service("druby://127.0.0.1:#{@drb_port}", ::FakeDrbSpecServer)
    end

    after(:each) do
      @service::stop_service
    end

    def run_spec_via_druby(argv)
      err, out = StringIO.new, StringIO.new
      RSpec::Core::Runner::DRbProxy.new(argv.push("--drb-port", @drb_port.to_s)).run(err, out)
      out.rewind
      out.read
    end

    it "returns true" do
      err, out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner::DRbProxy.new(["--drb-port", @drb_port.to_s]).run(err, out)
      result.should be_true
    end
    
    it "should output green colorized text when running with --colour option" do
      out = run_spec_via_druby(["--colour", dummy_spec_filename])
      out.should =~ /\e\[32m/m
    end
  
    it "should output red colorized text when running with -c option" do
      out = run_spec_via_druby(["-c", dummy_spec_filename])
      out.should =~ /\e\[31m/m
    end
    
    it "integrates via Runner.new.run" do
      err, out = StringIO.new, StringIO.new
      result = RSpec::Core::Runner.new.run(%W[ --drb --drb-port #{@drb_port} #{dummy_spec_filename}], err, out)
      result.should be_true
    end
  end
  
end
