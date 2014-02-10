require 'spec_helper'

module RSpec::Core::Formatters
  describe Loader do

    describe "#add(formatter)" do
      let(:loader) { Loader.new reporter }
      let(:output)     { StringIO.new }
      let(:path)       { File.join(Dir.tmpdir, 'output.txt') }
      let(:reporter)   { double "reporter", :register_listener => nil }

      it "adds to the list of formatters" do
        loader.add :documentation, output
        expect(loader.formatters.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by name (w/ Symbol)" do
        loader.add :documentation, output
        expect(loader.formatters.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by name (w/ String)" do
        loader.add 'documentation', output
        expect(loader.formatters.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by class" do
        formatter_class = Class.new(BaseTextFormatter)
        Loader.formatters[formatter_class] = []
        loader.add formatter_class, output
        expect(loader.formatters.first).to be_an_instance_of(formatter_class)
      end

      it "finds a formatter by class name" do
        stub_const("CustomFormatter", Class.new(BaseFormatter))
        Loader.formatters[CustomFormatter] = []
        loader.add "CustomFormatter", output
        expect(loader.formatters.first).to be_an_instance_of(CustomFormatter)
      end

      it "handles formatters that dont implement notifications" do
        formatter_class = Struct.new(:output)
        loader.add formatter_class, output
        expect(loader.formatters.first).to be_an_instance_of(RSpec::Core::Formatters::LegacyFormatter)
      end

      context "when a legacy formatter is added" do
        formatter_class = Struct.new(:output)

        it "issues a deprecation" do
          expect_warn_deprecation_with_call_site(__FILE__, __LINE__ + 2,
            /The #{formatter_class} formatter uses the deprecated formatter interface/)
          loader.add formatter_class, output
        end

        it "does not mistakenly add in the progress formatter" do
          # When we issue a deprecation warning it triggers `setup_defaults`,
          # which adds the progress formatter if it thinks no formatter has been
          # added yet.
          allow(RSpec).to receive(:warn_deprecation) do
            loader.setup_default(StringIO.new, StringIO.new)
          end

          loader.add formatter_class, output

          expect(loader.formatters.grep(RSpec::Core::Formatters::ProgressFormatter)).to eq([])
        end
      end

      it "finds a formatter by class fully qualified name" do
        stub_const("RSpec::CustomFormatter", (Class.new(BaseFormatter)))
        Loader.formatters[RSpec::CustomFormatter] = []
        loader.add "RSpec::CustomFormatter", output
        expect(loader.formatters.first).to be_an_instance_of(RSpec::CustomFormatter)
      end

      it "requires a formatter file based on its fully qualified name" do
        expect(loader).to receive(:require).with('rspec/custom_formatter') do
          stub_const("RSpec::CustomFormatter", (Class.new(BaseFormatter)))
          Loader.formatters[RSpec::CustomFormatter] = []
        end
        loader.add "RSpec::CustomFormatter", output
        expect(loader.formatters.first).to be_an_instance_of(RSpec::CustomFormatter)
      end

      it "raises NameError if class is unresolvable" do
        expect(loader).to receive(:require).with('rspec/custom_formatter3')
        expect { loader.add "RSpec::CustomFormatter3", output }.to raise_error(NameError)
      end

      it "raises ArgumentError if formatter is unknown" do
        expect { loader.add :progresss, output }.to raise_error(ArgumentError)
      end

      context "with a 2nd arg defining the output" do
        it "creates a file at that path and sets it as the output" do
          loader.add('doc', path)
          expect(loader.formatters.first.output).to be_a(File)
          expect(loader.formatters.first.output.path).to eq(path)
        end
      end

      context "when a duplicate formatter exists" do
        before { loader.add :documentation, output }

        it "doesn't add the formatter for the same output target" do
          expect {
            loader.add :documentation, output
          }.not_to change { loader.formatters.length }
        end

        it "adds the formatter for different output targets" do
          expect {
            loader.add :documentation, path
          }.to change { loader.formatters.length }
        end
      end
    end
  end
end
