module RSpec::Core
  RSpec.describe "config block hook filtering" do
    describe "unfiltered hooks" do
      it "is run" do
        filters = []
        RSpec.configure do |c|
          c.before(:all) { filters << "before all in config"}
          c.around(:each) {|example| filters << "around each in config"; example.run}
          c.before(:each) { filters << "before each in config"}
          c.after(:each) { filters << "after each in config"}
          c.after(:all) { filters << "after all in config"}
        end
        group = RSpec.describe
        group.example("example") {}
        group.run
        expect(filters).to eq([
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ])
      end
    end

    describe "hooks with single filters" do

      context "with no scope specified" do
        it "is run around|before|after :each if the filter matches the example group's filter" do
          filters = []
          RSpec.configure do |c|
            c.around(:match => true) {|example| filters << "around each in config"; example.run}
            c.before(:match => true) { filters << "before each in config"}
            c.after(:match => true)  { filters << "after each in config"}
          end
          group = RSpec.describe("group", :match => true)
          group.example("example") {}
          group.run
          expect(filters).to eq([
            "around each in config",
            "before each in config",
            "after each in config"
          ])
        end
      end

      it "is run if the filter matches the example group's filter" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :match => true) { filters << "before all in config"}
          c.around(:each, :match => true) {|example| filters << "around each in config"; example.run}
          c.before(:each, :match => true) { filters << "before each in config"}
          c.after(:each,  :match => true) { filters << "after each in config"}
          c.after(:all,   :match => true) { filters << "after all in config"}
        end
        group = RSpec.describe("group", :match => true)
        group.example("example") {}
        group.run
        expect(filters).to eq([
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ])
      end

      it "runs before|after :all hooks on matching nested example groups" do
        filters = []
        RSpec.configure do |c|
          c.before(:all, :match => true) { filters << :before_all }
          c.after(:all, :match => true)  { filters << :after_all }
        end

        example_1_filters = example_2_filters = nil

        group = RSpec.describe "group" do
          it("example 1") { example_1_filters = filters.dup }
          describe "subgroup", :match => true do
            it("example 2") { example_2_filters = filters.dup }
          end
        end
        group.run

        expect(example_1_filters).to be_empty
        expect(example_2_filters).to eq([:before_all])
        expect(filters).to eq([:before_all, :after_all])
      end

      it "runs before|after :all hooks only on the highest level group that matches the filter" do
        filters = []
        RSpec.configure do |c|
          c.before(:all, :match => true) { filters << :before_all }
          c.after(:all, :match => true)  { filters << :after_all }
        end

        example_1_filters = example_2_filters = example_3_filters = nil

        group = RSpec.describe "group", :match => true do
          it("example 1") { example_1_filters = filters.dup }
          describe "subgroup", :match => true do
            it("example 2") { example_2_filters = filters.dup }
            describe "sub-subgroup", :match => true do
              it("example 3") { example_3_filters = filters.dup }
            end
          end
        end
        group.run

        expect(example_1_filters).to eq([:before_all])
        expect(example_2_filters).to eq([:before_all])
        expect(example_3_filters).to eq([:before_all])

        expect(filters).to eq([:before_all, :after_all])
      end

      it "does not run if the filter doesn't match the example group's filter" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :match => false) { filters << "before all in config"}
          c.around(:each, :match => false) {|example| filters << "around each in config"; example.run}
          c.before(:each, :match => false) { filters << "before each in config"}
          c.after(:each,  :match => false) { filters << "after each in config"}
          c.after(:all,   :match => false) { filters << "after all in config"}
        end
        group = RSpec.describe(:match => true)
        group.example("example") {}
        group.run
        expect(filters).to eq([])
      end

      context "when the hook filters apply to individual examples instead of example groups" do
        let(:each_filters) { [] }
        let(:all_filters) { [] }

        let(:example_group) do
          md = example_metadata
          RSpec.describe do
            it("example", md) { }
          end
        end

        def filters
          each_filters + all_filters
        end

        before(:each) do
          af, ef = all_filters, each_filters

          RSpec.configure do |c|
            c.before(:all,  :foo => :bar) { af << "before all in config"}
            c.around(:each, :foo => :bar) {|example| ef << "around each in config"; example.run}
            c.before(:each, :foo => :bar) { ef << "before each in config"}
            c.after(:each,  :foo => :bar) { ef << "after each in config"}
            c.after(:all,   :foo => :bar) { af << "after all in config"}
          end

          example_group.run
        end

        describe 'an example with matching metadata' do
          let(:example_metadata) { { :foo => :bar } }

          it "runs the `:each` hooks" do
            expect(each_filters).to eq([
              'around each in config',
              'before each in config',
              'after each in config'
            ])
          end
        end

        describe 'an example without matching metadata' do
          let(:example_metadata) { { :foo => :bazz } }

          it "does not run any of the hooks" do
            expect(self.filters).to be_empty
          end
        end
      end
    end

    describe "hooks with multiple filters" do
      it "is run if all hook filters match the group's filters" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :one => 1)                         { filters << "before all in config"}
          c.around(:each, :two => 2, :one => 1)              {|example| filters << "around each in config"; example.run}
          c.before(:each, :one => 1, :two => 2)              { filters << "before each in config"}
          c.after(:each,  :one => 1, :two => 2, :three => 3) { filters << "after each in config"}
          c.after(:all,   :one => 1, :three => 3)            { filters << "after all in config"}
        end
        group = RSpec.describe("group", :one => 1, :two => 2, :three => 3)
        group.example("example") {}
        group.run
        expect(filters).to eq([
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ])
      end

      it "does not run if some hook filters don't match the group's filters" do
        sequence = []

        RSpec.configure do |c|
          c.before(:all,  :one => 1, :four => 4)                         { sequence << "before all in config"}
          c.around(:each, :two => 2, :four => 4)                         {|example| sequence << "around each in config"; example.run}
          c.before(:each, :one => 1, :two => 2, :four => 4)              { sequence << "before each in config"}
          c.after(:each,  :one => 1, :two => 2, :three => 3, :four => 4) { sequence << "after each in config"}
          c.after(:all,   :one => 1, :three => 3, :four => 4)            { sequence << "after all in config"}
        end

        RSpec.describe "group", :one => 1, :two => 2, :three => 3 do
          example("ex1") { sequence << "ex1" }
          example("ex2", :four => 4) { sequence << "ex2" }
        end.run

        expect(sequence).to eq([
          "ex1",
          "before all in config",
          "around each in config",
          "before each in config",
          "ex2",
          "after each in config",
          "after all in config"
        ])
      end

      it "does not run for examples that do not match, even if their group matches" do
        filters = []

        RSpec.configure do |c|
          c.before(:each, :apply_it) { filters << :before_each }
        end

        RSpec.describe "Group", :apply_it do
          example("ex1") { filters << :matching_example }
          example("ex2", :apply_it => false) { filters << :nonmatching_example }
        end.run

        expect(filters).to eq([:before_each, :matching_example, :nonmatching_example])
      end
    end

    describe ":context hooks defined in configuration with metadata" do
      it 'applies to individual matching examples' do
        sequence = []

        RSpec.configure do |config|
          config.before(:context, :apply_it) { sequence << :before_context }
          config.after(:context, :apply_it)  { sequence << :after_context  }
        end

        RSpec.describe do
          example("ex", :apply_it) { sequence << :example }
        end.run

        expect(sequence).to eq([:before_context, :example, :after_context])
      end

      it 'does not apply to individual matching examples for which it also applies to a parent example group' do
        sequence = []

        RSpec.configure do |config|
          config.before(:context, :apply_it) { sequence << :before_context }
          config.after(:context, :apply_it)  { sequence << :after_context  }
        end

        RSpec.describe "Group", :apply_it do
          example("ex") { sequence << :outer_example }

          context "nested", :apply_it => false do
            example("ex", :apply_it) { sequence << :inner_example }
          end
        end.run

        expect(sequence).to eq([:before_context, :outer_example, :inner_example, :after_context])
      end
    end
  end
end
