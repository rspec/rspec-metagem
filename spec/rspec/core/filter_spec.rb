require 'spec_helper'

module RSpec::Core
  describe Filter do
    %w[inclusions include exclusions exclude].each_slice(2) do |type, name|
      it "merges #{type}" do
        filter = Filter.new
        filter.exclusions.clear # defaults
        filter.send name, :foo => :bar
        filter.send name, :baz => :bam
        filter.send(type).should eq(:foo => :bar, :baz => :bam)
      end

      it "overrides previous #{type} (via merge)" do
        filter = Filter.new
        filter.exclusions.clear # defaults
        filter.send name, :foo => 1
        filter.send name, :foo => 2
        filter.send(type).should eq(:foo => 2)
      end

      it "ignores new #{type} if same key exists and priority is low" do
        filter = Filter.new
        filter.exclusions.clear # defaults
        filter.send name, :foo => 1
        filter.send name, :weak, :foo => 2
        filter.send(type).should eq(:foo => 1)
      end
    end

    describe "#prune" do
      it "includes objects with tags matching inclusions" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter = Filter.new
        filter.include :foo => :bar
        filter.prune([included, excluded]).should eq([included])
      end

      it "excludes objects with tags matching exclusions" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter = Filter.new
        filter.exclude :foo => :bar
        filter.prune([included, excluded]).should eq([included])
      end

      it "prefers exclusion when matches previously set inclusion" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter = Filter.new
        filter.include :foo => :bar
        filter.exclude :foo => :bar
        filter.filter([included, excluded]).should eq([included])
      end

      it "prefers inclusion when matches previously set exclusion" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter = Filter.new
        filter.exclude :foo => :bar
        filter.include :foo => :bar
        filter.filter([included, excluded]).should eq([included])
      end

      it "prefers previously set inclusion when exclusion matches but has lower priority" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter = Filter.new
        filter.include :foo => :bar
        filter.exclude :low, :foo => :bar
        filter.filter([included, excluded]).should eq([included])
      end

      it "prefers previously set exclusion when inclusion matches but has lower priority" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter = Filter.new
        filter.exclude :foo => :bar
        filter.include :low, :foo => :bar
        filter.filter([included, excluded]).should eq([included])
      end
    end

    describe "#inclusions#description" do
      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        lambda { }.inspect.should include(project_dir)
        lambda { }.inspect.should include(' (lambda)') if RUBY_VERSION > '1.9'
        lambda { }.inspect.should include('0x')

        filter = Filter.new
        filter.include :foo => lambda { }

        filter.inclusions.description.should_not include(project_dir)
        filter.inclusions.description.should_not include(' (lambda)')
        filter.inclusions.description.should_not include('0x')
      end
    end

    describe "#exclusions#description" do
      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        lambda { }.inspect.should include(project_dir)
        lambda { }.inspect.should include(' (lambda)') if RUBY_VERSION > '1.9'
        lambda { }.inspect.should include('0x')

        filter = Filter.new
        filter.exclude :foo => lambda { }

        filter.exclusions.description.should_not include(project_dir)
        filter.exclusions.description.should_not include(' (lambda)')
        filter.exclusions.description.should_not include('0x')
      end

      it 'returns `{}` when it only contains the default filters' do
        filter = Filter.new
        filter.exclusions.description.should eq({}.inspect)
      end

      it 'includes other filters' do
        filter = Filter.new
        filter.exclude :foo => :bar
        filter.exclusions.description.should eq({ :foo => :bar }.inspect)
      end

      it 'includes an overriden :if filter' do
        filter = Filter.new
        filter.exclude :if => :custom_filter
        filter.exclusions.description.should eq({ :if => :custom_filter }.inspect)
      end

      it 'includes an overriden :unless filter' do
        filter = Filter.new
        filter.exclude :unless => :custom_filter
        filter.exclusions.description.should eq({ :unless => :custom_filter }.inspect)
      end
    end
  end
end
