require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Rspec::Core::Formatters::BaseFormatter do
  
  before do
    @formatter = Rspec::Core::Formatters::BaseFormatter.new 
  end

  class HaveInterfaceMatcher
    def initialize(method)
      @method = method
    end

    attr_reader :object
    attr_reader :method

    def matches?(object)
      @object = object
      object.respond_to?(@method)
    end

    def with(arity)
      WithArity.new(self, @method, arity)
    end

    class WithArity
      def initialize(matcher, method, arity)
        @have_matcher = matcher
        @method = method
        @arity  = arity
      end

      def matches?(an_object)
        @have_matcher.matches?(an_object) && real_arity == @arity
      end

      def failure_message
        "#{@have_matcher} should have method :#{@method} with #{argument_arity}, but it had #{real_arity}"
      end

      def arguments
        self
      end

      alias_method :argument, :arguments

      private

      def real_arity
        @have_matcher.object.method(@method).arity
      end

      def argument_arity
        if @arity == 1
          "1 argument"
        else
          "#{@arity} arguments"
        end
      end
    end
  end

  def have_interface_for(method)
    HaveInterfaceMatcher.new(method)
  end

  it "should have start as an interface with one argument" do
    @formatter.should have_interface_for(:start).with(1).argument
  end

  it "should have add_behaviour as an interface with one argument" do
    @formatter.should have_interface_for(:add_behaviour).with(1).argument
  end

  it "should have example_finished as an interface with one argument" do
    @formatter.should have_interface_for(:example_finished).with(1).arguments
  end

  it "should have start_dump as an interface with 1 arguments" do
    @formatter.should have_interface_for(:start_dump).with(1).arguments
  end

  it "should have dump_failures as an interface with no arguments" do
    @formatter.should have_interface_for(:dump_failures).with(0).arguments
  end

  it "should have dump_summary as an interface with zero arguments" do
    @formatter.should have_interface_for(:dump_summary).with(0).arguments
  end

  it "should have dump_pending as an interface with zero arguments" do
    @formatter.should have_interface_for(:dump_pending).with(0).arguments
  end

  it "should have close as an interface with zero arguments" do
    @formatter.should have_interface_for(:close).with(0).arguments
  end
  
  describe '#format_backtrace' do
    
    it "should display the full backtrace when the example is given the :full_backtrace => true option", :full_backtrace => true
    
  end
  
end
