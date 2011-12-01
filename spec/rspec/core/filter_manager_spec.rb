require 'spec_helper'

module RSpec::Core
  describe FilterManager do
    %w[inclusions include exclusions exclude].each_slice(2) do |type, name|
      it "merges #{type}" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => :bar
        filter_manager.send name, :baz => :bam
        filter_manager.send(type).should eq(:foo => :bar, :baz => :bam)
      end

      it "overrides previous #{type} (via merge)" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => 1
        filter_manager.send name, :foo => 2
        filter_manager.send(type).should eq(:foo => 2)
      end

      it "ignores new #{type} if same key exists and priority is low" do
        filter_manager = FilterManager.new
        filter_manager.exclusions.clear # defaults
        filter_manager.send name, :foo => 1
        filter_manager.send name, :low_priority, :foo => 2
        filter_manager.send(type).should eq(:foo => 1)
      end
    end

    describe "#prune" do
      it "includes objects with tags matching inclusions" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      it "excludes objects with tags matching exclusions" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      it "prefers exclusion when matches previously set inclusion" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.exclude :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      it "prefers inclusion when matches previously set exclusion" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.include :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      it "prefers previously set inclusion when exclusion matches but has lower priority" do
        included = RSpec::Core::Metadata.new({:foo => :bar})
        excluded = RSpec::Core::Metadata.new
        filter_manager = FilterManager.new
        filter_manager.include :foo => :bar
        filter_manager.exclude :low_priority, :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end

      it "prefers previously set exclusion when inclusion matches but has lower priority" do
        included = RSpec::Core::Metadata.new
        excluded = RSpec::Core::Metadata.new({:foo => :bar})
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.include :low_priority, :foo => :bar
        filter_manager.prune([included, excluded]).should eq([included])
      end
    end

    describe "#inclusions#description" do
      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        lambda { }.inspect.should include(project_dir)
        lambda { }.inspect.should include(' (lambda)') if RUBY_VERSION > '1.9'
        lambda { }.inspect.should include('0x')

        filter_manager = FilterManager.new
        filter_manager.include :foo => lambda { }

        filter_manager.inclusions.description.should_not include(project_dir)
        filter_manager.inclusions.description.should_not include(' (lambda)')
        filter_manager.inclusions.description.should_not include('0x')
      end
    end

    describe "#exclusions#description" do
      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        lambda { }.inspect.should include(project_dir)
        lambda { }.inspect.should include(' (lambda)') if RUBY_VERSION > '1.9'
        lambda { }.inspect.should include('0x')

        filter_manager = FilterManager.new
        filter_manager.exclude :foo => lambda { }

        filter_manager.exclusions.description.should_not include(project_dir)
        filter_manager.exclusions.description.should_not include(' (lambda)')
        filter_manager.exclusions.description.should_not include('0x')
      end

      it 'returns `{}` when it only contains the default filters' do
        filter_manager = FilterManager.new
        filter_manager.exclusions.description.should eq({}.inspect)
      end

      it 'includes other filters' do
        filter_manager = FilterManager.new
        filter_manager.exclude :foo => :bar
        filter_manager.exclusions.description.should eq({ :foo => :bar }.inspect)
      end

      it 'deprecates an overridden :if filter' do
        RSpec.should_receive(:warn_deprecation).with(/exclude\(:if.*is deprecated/)
        filter_manager = FilterManager.new
        filter_manager.exclude :if => :custom_filter
      end

      it 'deprecates an overridden :unless filter' do
        RSpec.should_receive(:warn_deprecation).with(/exclude\(:unless.*is deprecated/)
        filter_manager = FilterManager.new
        filter_manager.exclude :unless => :custom_filter
      end

      it 'includes an overriden :if filter' do
        RSpec.stub(:warn_deprecation)
        filter_manager = FilterManager.new
        filter_manager.exclude :if => :custom_filter
        filter_manager.exclusions.description.should eq({ :if => :custom_filter }.inspect)
      end

      it 'includes an overriden :unless filter' do
        RSpec.stub(:warn_deprecation)
        filter_manager = FilterManager.new
        filter_manager.exclude :unless => :custom_filter
        filter_manager.exclusions.description.should eq({ :unless => :custom_filter }.inspect)
      end
    end

    it "clears the inclusion filter on include :line_numbers" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :line_numbers => [100]
      filter_manager.inclusions.should eq(:line_numbers => [100])
    end

    it "clears the inclusion filter on include :locations" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :locations => { "path/to/file.rb" => [37] }
      filter_manager.inclusions.should eq(:locations => { "path/to/file.rb" => [37] })
    end

    it "clears the inclusion filter on include :full_description" do
      filter_manager = FilterManager.new
      filter_manager.include :foo => :bar
      filter_manager.include :full_description => "this and that"
      filter_manager.inclusions.should eq(:full_description => "this and that")
    end
  end
end
