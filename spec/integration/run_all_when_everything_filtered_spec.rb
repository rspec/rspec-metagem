require 'support/aruba_support'

RSpec.describe 'The `run_all_when_everything_filtered` config option' do
  include_context "aruba support"
  before { clean_current_dir }

  context "when not set" do
    before do
      write_file "spec/example_spec.rb", "
        RSpec.describe 'examples' do
          it 'with a tag' do
          end

          it 'with no tag' do
          end
        end
      "
    end

    specify 'by default, no specs are run if they are all filtered out by an inclusion tag' do
      run_command "spec/example_spec.rb --tag some_tag"

      expect(last_cmd_stdout).to include("0 examples, 0 failures")
    end

    specify "specs are still run if they are filtered out by an exclusion tag" do
      run_command "spec/example_spec.rb --tag ~some_tag"

      expect(last_cmd_stdout).to include("2 examples, 0 failures")
    end
  end

  context "when set" do
    before do
      write_file "spec/example_spec.rb", "
        RSpec.configure do |c|
          c.run_all_when_everything_filtered = true
        end

        RSpec.describe 'examples' do
          it 'with a tag', :tag_1 do
          end

          it 'with no tag' do
          end
        end
      "
    end

    specify "if there are any matches for the filtering tag, only those features are run" do
      run_command "spec/example_spec.rb --tag tag_1"

      expect(last_cmd_stdout).to include(
        "1 example, 0 failures",
        "Run options: include {:tag_1=>true}"
      )
    end

    specify "all the specs are run when the tag has no matches" do
      run_command "spec/example_spec.rb --tag tag_2"

      expect(last_cmd_stdout).to include(
        "2 examples, 0 failures",
        "All examples were filtered out; ignoring {:tag_2=>true}"
      )
    end
  end
end
