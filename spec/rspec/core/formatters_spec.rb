require 'spec_helper'

module RSpec::Core::Formatters
  describe Collection do

    describe "#add(formatter)" do
      let(:collection) { Collection.new reporter }
      let(:output)     { StringIO.new }
      let(:path)       { File.join(Dir.tmpdir, 'output.txt') }
      let(:reporter)   { double "reporter", :register_listener => nil }

      it "adds to the list of formatters" do
        collection.add :documentation, output
        expect(collection.to_a.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by name (w/ Symbol)" do
        collection.add :documentation, output
        expect(collection.to_a.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by name (w/ String)" do
        collection.add 'documentation', output
        expect(collection.to_a.first).to be_an_instance_of(DocumentationFormatter)
      end

      it "finds a formatter by class" do
        formatter_class = Class.new(BaseTextFormatter)
        collection.add formatter_class, output
        expect(collection.to_a.first).to be_an_instance_of(formatter_class)
      end

      it "finds a formatter by class name" do
        stub_const("CustomFormatter", Class.new(BaseFormatter))
        collection.add "CustomFormatter", output
        expect(collection.to_a.first).to be_an_instance_of(CustomFormatter)
      end

      it "handles formatters that dont implement notifications" do
        formatter_class = Struct.new(:output)
        collection.add formatter_class, output
        expect(collection.to_a.first).to be_an_instance_of(RSpec::Core::Formatters::LegacyFormatter)
      end

      it "finds a formatter by class fully qualified name" do
        stub_const("RSpec::CustomFormatter", Class.new(BaseFormatter))
        collection.add "RSpec::CustomFormatter", output
        expect(collection.to_a.first).to be_an_instance_of(RSpec::CustomFormatter)
      end

      it "requires a formatter file based on its fully qualified name" do
        expect(collection).to receive(:require).with('rspec/custom_formatter') do
          stub_const("RSpec::CustomFormatter", Class.new(BaseFormatter))
        end
        collection.add "RSpec::CustomFormatter", output
        expect(collection.to_a.first).to be_an_instance_of(RSpec::CustomFormatter)
      end

      it "raises NameError if class is unresolvable" do
        expect(collection).to receive(:require).with('rspec/custom_formatter3')
        expect { collection.add "RSpec::CustomFormatter3", output }.to raise_error(NameError)
      end

      it "raises ArgumentError if formatter is unknown" do
        expect { collection.add :progresss, output }.to raise_error(ArgumentError)
      end

      context "with a 2nd arg defining the output" do
        it "creates a file at that path and sets it as the output" do
          collection.add('doc', path)
          expect(collection.to_a.first.output).to be_a(File)
          expect(collection.to_a.first.output.path).to eq(path)
        end
      end

      context "when a duplicate formatter exists" do
        before { collection.add :documentation, output }

        it "doesn't add the formatter for the same output target" do
          expect {
            collection.add :documentation, output
          }.not_to change { collection.to_a.length }
        end

        it "adds the formatter for different output targets" do
          expect {
            collection.add :documentation, path
          }.to change { collection.to_a.length }
        end
      end
    end
  end
end
