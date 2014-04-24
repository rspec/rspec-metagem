require 'spec_helper'

module RSpec::Core
  RSpec.describe FilterManager do
    def opposite(name)
      name =~ /^in/ ? name.sub(/^(in)/,'ex') : name.sub(/^(ex)/,'in')
    end

    subject(:filter_manager) { FilterManager.new }
    let(:inclusions) { filter_manager.inclusions }
    let(:exclusions) { filter_manager.exclusions }

    %w[include inclusions exclude exclusions].each_slice(2) do |name, type|
      describe "##{name}" do
        subject(:rules) { send(type).rules }
        let(:opposite_rules) { send(opposite(type)).rules }

        it "merges #{type}" do
          filter_manager.send name, :foo => :bar
          filter_manager.send name, :baz => :bam
          expect(rules).to eq(:foo => :bar, :baz => :bam)
        end

        it "overrides previous #{type} with (via merge)" do
          filter_manager.send name, :foo => 1
          filter_manager.send name, :foo => 2
          expect(rules).to eq(:foo => 2)
        end

        it "deletes matching opposites" do
          filter_manager.exclusions.clear # defaults
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send name, :foo => 2
          expect(rules).to eq(:foo => 2)
          expect(opposite_rules).to be_empty
        end

        if name == "include"
          [:locations, :full_description].each do |filter|
            context "with :#{filter}" do
              it "clears previous inclusions" do
                filter_manager.include :foo => :bar
                filter_manager.include filter => "value"
                expect(rules).to eq({filter => "value"})
              end

              it "does not clear previous exclusions" do
                filter_manager.exclude :foo => :bar
                filter_manager.include filter => "value"
                expect(exclusions.rules).to eq(:foo => :bar)
              end

              it "does nothing when :#{filter} previously set" do
                filter_manager.include filter => "a_value"
                filter_manager.include :foo => :bar
                expect(rules).to eq(filter => "a_value")
              end
            end
          end
        end
      end

      describe "##{name}_only" do
        subject(:rules) { send(type).rules }
        let(:opposite_rules) { send(opposite(type)).rules }

        it "replaces existing #{type}" do
          filter_manager.send name, :foo => 1, :bar => 2
          filter_manager.send "#{name}_only", :foo => 3
          expect(rules).to eq(:foo => 3)
        end

        it "deletes matching opposites" do
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}_only", :foo => 2
          expect(rules).to eq(:foo => 2)
          expect(opposite_rules).to be_empty
        end
      end

      describe "##{name}_with_low_priority" do
        subject(:rules) { send(type).rules }
        let(:opposite_rules) { send(opposite(type)).rules }

        it "ignores new #{type} if same key exists" do
          filter_manager.send name, :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 2
          expect(rules).to eq(:foo => 1)
        end

        it "ignores new #{type} if same key exists in opposite" do
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 1
          expect(rules).to be_empty
          expect(opposite_rules).to eq(:foo => 1)
        end

        it "keeps new #{type} if same key exists in opposite but values are different" do
          filter_manager.send opposite(name), :foo => 1
          filter_manager.send "#{name}_with_low_priority", :foo => 2
          expect(rules).to eq(:foo => 2)
          expect(opposite_rules).to eq(:foo => 1)
        end
      end
    end

    describe "#prune" do
      def example_with(*args)
        RSpec.describe("group", *args).example("example")
      end

      it "prefers location to exclusion filter" do
        group = RSpec.describe("group")
        included = group.example("include", :slow => true) {}
        excluded = group.example("exclude") {}
        filter_manager.add_location(__FILE__, [__LINE__ - 2])
        filter_manager.exclude_with_low_priority :slow => true
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers location to exclusion filter on entire group" do
        # We way want to change this behaviour in future, see:
        # https://github.com/rspec/rspec-core/issues/779
        group = RSpec.describe("group")
        included = group.example("include", :slow => true) {}
        excluded = example_with
        filter_manager.add_location(__FILE__, [__LINE__ - 3])
        filter_manager.exclude_with_low_priority :slow => true
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers description to exclusion filter" do
        group = RSpec.describe("group")
        included = group.example("include", :slow => true) {}
        excluded = group.example("exclude") {}
        filter_manager.include(:full_description => /include/)
        filter_manager.exclude_with_low_priority :slow => true
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "includes objects with tags matching inclusions" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager.include :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "excludes objects with tags matching exclusions" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager.exclude :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers exclusion when matches previously set inclusion" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager.include :foo => :bar
        filter_manager.exclude :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers inclusion when matches previously set exclusion" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager.exclude :foo => :bar
        filter_manager.include :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers previously set inclusion when exclusion matches but has lower priority" do
        included = example_with({:foo => :bar})
        excluded = example_with
        filter_manager.include :foo => :bar
        filter_manager.exclude_with_low_priority :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end

      it "prefers previously set exclusion when inclusion matches but has lower priority" do
        included = example_with
        excluded = example_with({:foo => :bar})
        filter_manager.exclude :foo => :bar
        filter_manager.include_with_low_priority :foo => :bar
        expect(filter_manager.prune([included, excluded])).to eq([included])
      end
    end

    describe "#inclusions#description" do
      subject(:description) { inclusions.description }

      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        expect(lambda { }.inspect).to include(project_dir)
        expect(lambda { }.inspect).to include(' (lambda)') if RUBY_VERSION > '1.9'
        expect(lambda { }.inspect).to include('0x')

        filter_manager.include :foo => lambda { }

        expect(description).not_to include(project_dir)
        expect(description).not_to include(' (lambda)')
        expect(description).not_to include('0x')
      end
    end

    describe "#exclusions#description" do
      subject(:description) { exclusions.description }

      it 'cleans up the description' do
        project_dir = File.expand_path('.')
        expect(lambda { }.inspect).to include(project_dir)
        expect(lambda { }.inspect).to include(' (lambda)') if RUBY_VERSION > '1.9'
        expect(lambda { }.inspect).to include('0x')

        filter_manager.exclude :foo => lambda { }

        expect(description).not_to include(project_dir)
        expect(description).not_to include(' (lambda)')
        expect(description).not_to include('0x')
      end

      it 'returns `{}` when it only contains the default filters' do
        expect(description).to eq({}.inspect)
      end

      it 'includes other filters' do
        filter_manager.exclude :foo => :bar
        expect(description).to eq({ :foo => :bar }.inspect)
      end

      it 'includes an overriden :if filter' do
        allow(RSpec).to receive(:deprecate)
        filter_manager.exclude :if => :custom_filter
        expect(description).to eq({ :if => :custom_filter }.inspect)
      end

      it 'includes an overriden :unless filter' do
        allow(RSpec).to receive(:deprecate)
        filter_manager.exclude :unless => :custom_filter
        expect(description).to eq({ :unless => :custom_filter }.inspect)
      end
    end

    describe ":if and :unless ExclusionFilters" do
      def example_with_metadata(metadata)
        value = nil
        RSpec.describe("group") do
          value = example('arbitrary example', metadata)
        end
        value
      end

      describe "the default :if filter" do
        it "does not exclude a spec with  { :if => true } metadata" do
          example = example_with_metadata(:if => true)
          expect(filter_manager.exclude?(example)).to be_falsey
        end

        it "excludes a spec with  { :if => false } metadata" do
          example = example_with_metadata(:if => false)
          expect(filter_manager.exclude?(example)).to be_truthy
        end

        it "excludes a spec with  { :if => nil } metadata" do
          example = example_with_metadata(:if => nil)
          expect(filter_manager.exclude?(example)).to be_truthy
        end
      end

      describe "the default :unless filter" do
        it "excludes a spec with  { :unless => true } metadata" do
          example = example_with_metadata(:unless => true)
          expect(filter_manager.exclude?(example)).to be_truthy
        end

        it "does not exclude a spec with { :unless => false } metadata" do
          example = example_with_metadata(:unless => false)
          expect(filter_manager.exclude?(example)).to be_falsey
        end

        it "does not exclude a spec with { :unless => nil } metadata" do
          example = example_with_metadata(:unless => nil)
          expect(filter_manager.exclude?(example)).to be_falsey
        end
      end
    end
  end
end
