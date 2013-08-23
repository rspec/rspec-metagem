module RSpec
  describe Expectations do
    def file_contents_for(lib, filename)
      path = $LOAD_PATH.find { |p| p.include?("/#{lib}/lib") }
      file = File.join(path, filename)
      File.read(file)
    end

    it 'has an up-to-date rspec/caller_filter file' do
      expectations = file_contents_for("rspec-expectations", "rspec/caller_filter.rb")
      core         = file_contents_for("rspec-core",         "rspec/caller_filter.rb")

      expect(expectations).to eq(core)
    end
  end
end

