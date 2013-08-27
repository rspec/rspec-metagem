module RSpec
  describe Expectations do
    def file_contents_for(lib, filename)
      # http://rubular.com/r/HYpUMftlG2
      path = $LOAD_PATH.find { |p| p.match(/\/rspec-#{lib}(-[a-f0-9]+)?\/lib/) }
      file = File.join(path, filename)
      File.read(file)
    end

    it 'has an up-to-date caller_filter file' do
      expectations = file_contents_for("expectations", "rspec/expectations/caller_filter.rb")
      core         = file_contents_for("core",         "rspec/core/caller_filter.rb")

      expect(expectations).to eq(core)
    end

    describe '.method_handle_for(object, method_name)' do

      class UntamperedClass
        def foo
          :bar
        end
      end

      class ClassWithMethodOverridden < UntamperedClass
        def method
          :baz
        end
      end

      class BasicClass < BasicObject
        def foo
          :bar
        end
      end

      class BasicClassWithKernel < BasicClass
        include ::Kernel
      end

      it 'fetches method definitions for vanilla objects' do
        object = UntamperedClass.new
        expect(Expectations.method_handle_for(object, :foo).call).to eq :bar
      end

      it 'fetches method definitions for objects with method redefined' do
        object = ClassWithMethodOverridden.new
        expect(Expectations.method_handle_for(object, :foo).call).to eq :bar
      end

      it 'fetches method definitions for basic objects' do
        object = BasicClass.new
        expect(Expectations.method_handle_for(object, :foo).call).to eq :bar
      end

      it 'fetches method definitions for basic objects with kernel mixed in' do
        object = BasicClassWithKernel.new
        expect(Expectations.method_handle_for(object, :foo).call).to eq :bar
      end
    end
  end
end
