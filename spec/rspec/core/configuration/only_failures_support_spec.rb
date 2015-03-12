module RSpec::Core
  RSpec.describe Configuration, "--only-failures support" do
    let(:config) { Configuration.new }

    def simulate_persisted_examples(*examples)
      config.example_status_persistence_file_path = "examples.txt"
      persister = class_double(ExampleStatusPersister).as_stubbed_const

      allow(persister).to receive(:load_from).with("examples.txt").and_return(examples.flatten)
    end

    describe "#last_run_statuses" do
      def last_run_statuses
        config.last_run_statuses
      end

      context "when `example_status_persistence_file_path` is configured" do
        before do
          simulate_persisted_examples(
            { :example_id => "id_1", :status => "passed" },
            { :example_id => "id_2", :status => "failed" }
          )
        end

        it 'gets the last run statuses from the ExampleStatusPersister' do
          expect(last_run_statuses).to eq(
            'id_1' => 'passed', 'id_2' => 'failed'
          )
        end

        it 'returns a memoized value' do
          expect(last_run_statuses).to be(last_run_statuses)
        end
      end

      context "when `example_status_persistence_file_path` is not configured" do
        it 'returns a memoized value' do
          expect(last_run_statuses).to be(last_run_statuses)
        end

        it 'returns a blank hash without attempting to load the persisted statuses' do
          config.example_status_persistence_file_path = nil

          persister = class_double(ExampleStatusPersister).as_stubbed_const
          expect(persister).not_to receive(:load_from)

          expect(last_run_statuses).to eq({})
        end
      end

      def allows_value_to_change_when_updated
        simulate_persisted_examples(
          { :example_id => "id_1", :status => "passed" },
          { :example_id => "id_2", :status => "failed" }
        )

        config.example_status_persistence_file_path = nil

        expect {
          yield
        }.to change { last_run_statuses }.to('id_1' => 'passed', 'id_2' => 'failed')
      end

      it 'allows the value to be updated when `example_status_persistence_file_path` is set after first access' do
        allows_value_to_change_when_updated do
          config.example_status_persistence_file_path = "examples.txt"
        end
      end

      it 'allows the value to be updated when `example_status_persistence_file_path` is forced after first access' do
        allows_value_to_change_when_updated do
          config.force(:example_status_persistence_file_path => "examples.txt")
        end
      end
    end

    describe "#spec_files_with_failures" do
      def spec_files_with_failures
        config.spec_files_with_failures
      end

      context "when `example_status_persistence_file_path` is configured" do
        it 'returns a memoized array of unique spec files that contain failed exaples' do
          simulate_persisted_examples(
            { :example_id => "./spec_1.rb[1:1]", :status => "failed"  },
            { :example_id => "./spec_1.rb[1:2]", :status => "failed"  },
            { :example_id => "./spec_2.rb[1:2]", :status => "passed"  },
            { :example_id => "./spec_3.rb[1:2]", :status => "pending" },
            { :example_id => "./spec_4.rb[1:2]", :status => "unknown" },
            { :example_id => "./spec_5.rb[1:2]", :status => "failed"  }
          )

          expect(spec_files_with_failures).to(
            be_an(Array) &
            be(spec_files_with_failures) &
            contain_exactly("./spec_1.rb", "./spec_5.rb")
          )
        end
      end

      context "when `example_status_persistence_file_path` is not configured" do
        it "returns a memoized blank array" do
          config.example_status_persistence_file_path = nil

          expect(spec_files_with_failures).to(
            eq([]) & be(spec_files_with_failures)
          )
        end
      end

      def allows_value_to_change_when_updated
        simulate_persisted_examples({ :example_id => "./spec_1.rb[1:1]", :status => "failed" })

        config.example_status_persistence_file_path = nil

        expect {
          yield
        }.to change { spec_files_with_failures }.to(["./spec_1.rb"])
      end

      it 'allows the value to be updated when `example_status_persistence_file_path` is set after first access' do
        allows_value_to_change_when_updated do
          config.example_status_persistence_file_path = "examples.txt"
        end
      end

      it 'allows the value to be updated when `example_status_persistence_file_path` is forced after first access' do
        allows_value_to_change_when_updated do
          config.force(:example_status_persistence_file_path => "examples.txt")
        end
      end
    end

    describe "#files_to_run, when `only_failures` is set" do
      around { |ex| Dir.chdir("spec/rspec/core", &ex) }
      let(:default_path) { "resources" }
      let(:files_with_failures) { ["resources/a_spec.rb"] }
      let(:files_loaded_via_default_path) do
        configuration = Configuration.new
        configuration.default_path = default_path
        configuration.files_or_directories_to_run = []
        configuration.files_to_run
      end

      before do
        expect(files_loaded_via_default_path).not_to eq(files_with_failures)
        config.default_path = default_path

        simulate_persisted_examples(files_with_failures.map do |file|
          { :example_id => "#{file}[1:1]", :status => "failed" }
        end)

        config.force(:only_failures => true)
      end

      context "and no explicit paths have been set" do
        it 'loads only the files that have failures' do
          config.files_or_directories_to_run = []
          expect(config.files_to_run).to eq(files_with_failures)
        end

        it 'loads the default path if there are no files with failures' do
          simulate_persisted_examples([])
          config.files_or_directories_to_run = []
          expect(config.files_to_run).to eq(files_loaded_via_default_path)
        end
      end

      context "and a path has been set" do
        it "ignores the list of files with failures, loading the configured path instead" do
          config.files_or_directories_to_run = ["resources/acceptance"]
          expect(config.files_to_run).to contain_files("resources/acceptance/foo_spec.rb")
        end
      end

      context "and the default path has been explicitly set" do
        it "ignores the list of files with failures, loading the configured path instead" do
          config.files_or_directories_to_run = [default_path]
          expect(config.files_to_run).to eq(files_loaded_via_default_path)
        end
      end
    end
  end
end
