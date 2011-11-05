require 'spec_helper'

module RSpec::Core
  describe Filter do
    %w[inclusions include exclusions exclude].each_slice(2) do |type, name|
      it "merges #{type}" do
        filter = Filter.new
        filter.send name, :foo => :bar
        filter.send name, :baz => :bam
        filter.send(type).should eq(:foo => :bar, :baz => :bam)
      end

      it "overrides previous #{type} (via merge)" do
        filter = Filter.new
        filter.send name, :foo => 1
        filter.send name, :foo => 2
        filter.send(type).should eq(:foo => 2)
      end

      it "ignores new #{type} if same key exists and priority is low" do
        filter = Filter.new
        filter.send name, :foo => 1
        filter.send name, :weak, :foo => 2
        filter.send(type).should eq(:foo => 1)
      end
    end

    it "includes objects with tags matching inclusions" do
      included = RSpec::Core::Metadata.new({:foo => :bar})
      excluded = RSpec::Core::Metadata.new
      filter = Filter.new
      filter.include :foo => :bar
      filter.filter([included, excluded]).should eq([included])
    end

    it "excludes objects with tags matching exclusions" do
      included = RSpec::Core::Metadata.new
      excluded = RSpec::Core::Metadata.new({:foo => :bar})
      filter = Filter.new
      filter.exclude :foo => :bar
      filter.filter([included, excluded]).should eq([included])
    end

    it "excludes objects matching exclusion and inclusion" do
      included = RSpec::Core::Metadata.new({:foo => :bar})
      excluded = RSpec::Core::Metadata.new({:foo => :bar, :baz => :bam})
      filter = Filter.new
      filter.include :foo => :bar
      filter.exclude :baz => :bam
      filter.filter([included, excluded]).should eq([included])
    end
  end
end
