require "spec_helper"

module RSpec::Core
  describe OptionParser do
    before do
      RSpec.stub(:deprecate)
    end

    let(:output_file){ mock File }

    before do
      File.stub(:open).with("foo.txt",'w') { (output_file) }
    end

    it "does not parse empty args" do
      parser = Parser.new
      OptionParser.should_not_receive(:new)
      parser.parse!([])
    end

    describe "--formatter" do
      it "is deprecated" do
        RSpec.should_receive(:deprecate)
        Parser.parse!(%w[--formatter doc])
      end

      it "gets converted to --format" do
        options = Parser.parse!(%w[--formatter doc])
        options[:formatters].first.should eq(["doc"])
      end
    end

    describe "--format" do
      it "defines the formatter" do
        options = Parser.parse!(%w[--format doc])
        options[:formatters].first.should eq(["doc"])
      end
    end

    describe "-f" do
      it "defines the formatter" do
        options = Parser.parse!(%w[-f doc])
        options[:formatters].first.should eq(["doc"])
      end
    end

    %w[--out -o].each do |option|
      describe option do
        let(:options) { Parser.parse!([option, 'out.txt']) }

        it "sets the output stream for the formatter" do
          options[:formatters].last.should eq(['progress', 'out.txt'])
        end

        context "with multiple formatters" do
          context "after last formatter" do
            it "sets the output stream for the last formatter" do
              options = Parser.parse!(['-f', 'progress', '-f', 'doc', option, 'out.txt'])
              options[:formatters][0].should eq(['progress'])
              options[:formatters][1].should eq(['doc', 'out.txt'])
            end
          end

          context "after first formatter" do
            it "sets the output stream for the first formatter" do
              options = Parser.parse!(['-f', 'progress', option, 'out.txt', '-f', 'doc'])
              options[:formatters][0].should eq(['progress', 'out.txt'])
              options[:formatters][1].should eq(['doc'])
            end
          end
        end
      end
    end
  end
end
