require 'tmpdir'
require 'rspec/support/spec/in_sub_process'

module RSpec::Core

  RSpec.describe Configuration do
    include RSpec::Support::InSubProcess

    let(:config) { Configuration.new }
    let(:exclusion_filter) { config.exclusion_filter.rules }
    let(:inclusion_filter) { config.inclusion_filter.rules }

    shared_examples_for "warning of deprecated `:example_group` during filtering configuration" do |method, *args|
      it "issues a deprecation warning when filtering by `:example_group`" do
        args << { :example_group => { :file_location => /spec\/unit/ } }
        expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /:example_group/)
        config.__send__(method, *args)
      end
    end

    describe '#deprecation_stream' do
      it 'defaults to standard error' do
        expect($rspec_core_without_stderr_monkey_patch.deprecation_stream).to eq STDERR
      end

      it 'is configurable' do
        io = double 'deprecation io'
        config.deprecation_stream = io
        expect(config.deprecation_stream).to eq io
      end

      context 'when the reporter has already been initialized' do
        before do
          config.reporter
          allow(config).to receive(:warn)
        end

        it 'prints a notice indicating the reconfigured output_stream will be ignored' do
          config.deprecation_stream = double("IO")
          expect(config).to have_received(:warn).with(/deprecation_stream.*#{__FILE__}:#{__LINE__ - 1}/)
        end

        it 'does not change the value of `deprecation_stream`' do
          value = config.deprecation_stream
          config.deprecation_stream = double("IO")
          expect(config.deprecation_stream).to equal(value)
        end

        it 'does not print a warning if set to the value it already has' do
          config.deprecation_stream = config.deprecation_stream
          expect(config).not_to have_received(:warn)
        end
      end
    end

    describe "#output_stream" do
      it 'defaults to standard output' do
        expect(config.output_stream).to eq $stdout
      end

      it 'is configurable' do
        io = double 'output io'
        config.output_stream = io
        expect(config.output_stream).to eq io
      end

      context 'when the reporter has already been initialized' do
        before do
          config.reporter
          allow(config).to receive(:warn)
        end

        it 'prints a notice indicating the reconfigured output_stream will be ignored' do
          config.output_stream = StringIO.new
          expect(config).to have_received(:warn).with(/output_stream.*#{__FILE__}:#{__LINE__ - 1}/)
        end

        it 'does not change the value of `output_stream`' do
          config.output_stream = StringIO.new
          expect(config.output_stream).to eq($stdout)
        end

        it 'does not print a warning if set to the value it already has' do
          config.output_stream = config.output_stream
          expect(config).not_to have_received(:warn)
        end
      end
    end

    describe "#requires=" do
      def absolute_path_to(dir)
        File.expand_path("../../../../#{dir}", __FILE__)
      end

      it 'adds `lib` to the load path' do
        lib_dir = absolute_path_to("lib")
        $LOAD_PATH.delete(lib_dir)

        expect($LOAD_PATH).not_to include(lib_dir)
        config.requires = []
        expect($LOAD_PATH).to include(lib_dir)
      end

      it 'adds the configured `default_path` to the load path' do
        config.default_path = 'features'
        foo_dir = absolute_path_to("features")

        expect($LOAD_PATH).not_to include(foo_dir)
        config.requires = []
        expect($LOAD_PATH).to include(foo_dir)
      end

      it 'stores the required files' do
        expect(config).to receive(:require).with('a/path')
        config.requires = ['a/path']
        expect(config.requires).to eq ['a/path']
      end

      context "when `default_path` refers to a file rather than a directory" do
        it 'does not add it to the load path' do
          config.default_path = 'Rakefile'
          config.requires = []
          expect($LOAD_PATH).not_to include(match(/Rakefile/))
        end
      end
    end

    describe "#load_spec_files" do
      it "loads files using load" do
        config.files_to_run = ["foo.bar", "blah_spec.rb"]
        expect(config).to receive(:load).twice
        config.load_spec_files
      end

      it "loads each file once, even if duplicated in list" do
        config.files_to_run = ["a_spec.rb", "a_spec.rb"]
        expect(config).to receive(:load).once
        config.load_spec_files
      end
    end

    describe "#mock_framework" do
      it "defaults to :rspec" do
        expect(RSpec::Support).to receive(:require_rspec_core).with('mocking_adapters/rspec')
        expect(config.mock_framework).to eq(MockingAdapters::RSpec)
      end

      context "when rspec-mocks is not installed" do
        it 'gracefully falls back to :nothing' do
          allow(RSpec::Support).to receive(:require_rspec_core).and_call_original
          allow(RSpec::Support).to receive(:require_rspec_core).with('mocking_adapters/rspec').and_raise(LoadError)

          expect(config.mock_framework).to eq(MockingAdapters::Null)
        end
      end
    end

    describe "#mock_framework="do
      it "delegates to mock_with" do
        expect(config).to receive(:mock_with).with(:rspec)
        config.mock_framework = :rspec
      end
    end

    shared_examples "a configurable framework adapter" do |m|
      it "yields a config object if the framework_module supports it" do
        custom_config = Struct.new(:custom_setting).new
        mod = Module.new
        allow(mod).to receive_messages(:configuration => custom_config)

        config.send m, mod do |mod_config|
          mod_config.custom_setting = true
        end

        expect(custom_config.custom_setting).to be_truthy
      end

      it "raises if framework module doesn't support configuration" do
        mod = Module.new

        expect {
          config.send m, mod do |mod_config|
          end
        }.to raise_error(/must respond to `configuration`/)
      end
    end

    describe "#mock_with" do
      before { allow(config).to receive(:require) }

      it_behaves_like "a configurable framework adapter", :mock_with

      it "allows rspec-mocks to be configured with a provided block" do
        mod = Module.new

        expect(RSpec::Mocks.configuration).to receive(:add_stub_and_should_receive_to).with(mod)

        config.mock_with :rspec do |c|
          c.add_stub_and_should_receive_to mod
        end
      end

      context "with a module" do
        it "sets the mock_framework_adapter to that module" do
          mod = Module.new
          config.mock_with mod
          expect(config.mock_framework).to eq(mod)
        end
      end

      it 'uses the named adapter' do
        expect(RSpec::Support).to receive(:require_rspec_core).with('mocking_adapters/mocha')
        stub_const("RSpec::Core::MockingAdapters::Mocha", Module.new)
        config.mock_with :mocha
      end

      it "uses the null adapter when given :nothing" do
        expect(RSpec::Support).to receive(:require_rspec_core).with('mocking_adapters/null').and_call_original
        config.mock_with :nothing
      end

      it "raises an error when given an unknown key" do
        expect {
          config.mock_with :crazy_new_mocking_framework_ive_not_yet_heard_of
        }.to raise_error(ArgumentError, /unknown mocking framework/i)
      end

      it "raises an error when given another type of object" do
        expect {
          config.mock_with Object.new
        }.to raise_error(ArgumentError, /unknown mocking framework/i)
      end

      context 'when there are already some example groups defined' do
        before { allow(RSpec::Support).to receive(:require_rspec_core) }

        it 'raises an error since this setting must be applied before any groups are defined' do
          allow(RSpec.world).to receive(:example_groups).and_return([double.as_null_object])
          mocha = stub_const("RSpec::Core::MockingAdapters::Mocha", Module.new)
          allow(mocha).to receive_messages(:framework_name => :mocha)

          expect {
            config.mock_with :mocha
          }.to raise_error(/must be configured before any example groups are defined/)
        end

        it 'does not raise an error if the default `mock_with :rspec` is re-configured' do
          config.mock_framework # called by RSpec when configuring the first example group
          allow(RSpec.world).to receive(:example_groups).and_return([double.as_null_object])
          config.mock_with :rspec
        end

        it 'does not raise an error if re-setting the same config' do
          mocha = stub_const("RSpec::Core::MockingAdapters::Mocha", Module.new)
          allow(mocha).to receive_messages(:framework_name => :mocha)

          groups = []
          allow(RSpec.world).to receive_messages(:example_groups => groups)
          config.mock_with :mocha
          groups << double.as_null_object
          config.mock_with :mocha
        end
      end
    end

    describe "#expectation_frameworks" do
      it "defaults to :rspec" do
        expect(config).to receive(:require).with('rspec/expectations')
        expect(config.expectation_frameworks).to eq([RSpec::Matchers])
      end

      context "when rspec-expectations is not installed" do
        def an_anonymous_module
          name = RUBY_VERSION.to_f < 1.9 ? '' : nil
          an_object_having_attributes(:class => Module, :name => name)
        end

        it 'gracefully falls back to an anonymous module' do
          allow(config).to receive(:require).with('rspec/expectations').and_raise(LoadError)
          expect(config.expectation_frameworks).to match([an_anonymous_module])
        end
      end
    end

    describe "#expectation_framework=" do
      it "delegates to expect_with" do
        expect(config).to receive(:expect_with).with(:rspec)
        config.expectation_framework = :rspec
      end
    end

    def stub_expectation_adapters
      stub_const("Test::Unit::Assertions", Module.new)
      stub_const("Minitest::Assertions", Module.new)
      stub_const("RSpec::Core::TestUnitAssertionsAdapter", Module.new)
      stub_const("RSpec::Core::MinitestAssertionsAdapter", Module.new)
      allow(config).to receive(:require)
    end

    describe "#expect_with" do
      before do
        stub_expectation_adapters
      end

      it_behaves_like "a configurable framework adapter", :expect_with

      context "with :rspec" do
        it "requires rspec/expectations" do
          expect(config).to receive(:require).with('rspec/expectations')
          config.expect_with :rspec
        end

        it "sets the expectation framework to ::RSpec::Matchers" do
          config.expect_with :rspec
          expect(config.expectation_frameworks).to eq [::RSpec::Matchers]
        end
      end

      context "with :test_unit" do
        it "requires rspec/core/test_unit_assertions_adapter" do
          expect(config).to receive(:require).
            with('rspec/core/test_unit_assertions_adapter')
          config.expect_with :test_unit
        end

        it "sets the expectation framework to ::Test::Unit::Assertions" do
          config.expect_with :test_unit
          expect(config.expectation_frameworks).to eq [
            ::RSpec::Core::TestUnitAssertionsAdapter
          ]
        end
      end

      context "with :minitest" do
        it "requires rspec/core/minitest_assertions_adapter" do
          expect(config).to receive(:require).
            with('rspec/core/minitest_assertions_adapter')
          config.expect_with :minitest
        end

        it "sets the expectation framework to ::Minitest::Assertions" do
          config.expect_with :minitest
          expect(config.expectation_frameworks).to eq [
            ::RSpec::Core::MinitestAssertionsAdapter
          ]
        end
      end

      it "supports multiple calls" do
        config.expect_with :rspec
        config.expect_with :minitest
        expect(config.expectation_frameworks).to eq [
          RSpec::Matchers,
          RSpec::Core::MinitestAssertionsAdapter
        ]
      end

      it "raises if block given with multiple args" do
        expect {
          config.expect_with :rspec, :minitest do |mod_config|
          end
        }.to raise_error(/expect_with only accepts/)
      end

      it "raises ArgumentError if framework is not supported" do
        expect do
          config.expect_with :not_supported
        end.to raise_error(ArgumentError)
      end

      context 'when there are already some example groups defined' do
        it 'raises an error since this setting must be applied before any groups are defined' do
          allow(RSpec.world).to receive(:example_groups).and_return([double.as_null_object])
          expect {
            config.expect_with :rspec
          }.to raise_error(/must be configured before any example groups are defined/)
        end

        it 'does not raise an error if the default `expect_with :rspec` is re-configured' do
          config.expectation_frameworks # called by RSpec when configuring the first example group
          allow(RSpec.world).to receive(:example_groups).and_return([double.as_null_object])
          config.expect_with :rspec
        end

        it 'does not raise an error if re-setting the same config' do
          groups = []
          allow(RSpec.world).to receive_messages(:example_groups => groups)
          config.expect_with :minitest
          groups << double.as_null_object
          config.expect_with :minitest
        end
      end
    end

    describe "#expecting_with_rspec?" do
      before do
        stub_expectation_adapters
      end

      it "returns false by default" do
        expect(config).not_to be_expecting_with_rspec
      end

      it "returns true when `expect_with :rspec` has been configured" do
        config.expect_with :rspec
        expect(config).to be_expecting_with_rspec
      end

      it "returns true when `expect_with :rspec, :minitest` has been configured" do
        config.expect_with :rspec, :minitest
        expect(config).to be_expecting_with_rspec
      end

      it "returns true when `expect_with :minitest, :rspec` has been configured" do
        config.expect_with :minitest, :rspec
        expect(config).to be_expecting_with_rspec
      end

      it "returns false when `expect_with :minitest` has been configured" do
        config.expect_with :minitest
        expect(config).not_to be_expecting_with_rspec
      end
    end

    describe "#files_to_run" do
      it "loads files not following pattern if named explicitly" do
        assign_files_or_directories_to_run "spec/rspec/core/resources/a_bar.rb"
        expect(config.files_to_run).to contain_files("spec/rspec/core/resources/a_bar.rb")
      end

      it "prevents repetition of dir when start of the pattern" do
        config.pattern = "spec/**/a_spec.rb"
        assign_files_or_directories_to_run "spec"
        expect(config.files_to_run).to contain_files("spec/rspec/core/resources/a_spec.rb")
      end

      it "does not prevent repetition of dir when later of the pattern" do
        config.pattern = "rspec/**/a_spec.rb"
        assign_files_or_directories_to_run "spec"
        expect(config.files_to_run).to contain_files("spec/rspec/core/resources/a_spec.rb")
      end

      it "supports patterns starting with ./" do
        config.pattern = "./spec/**/a_spec.rb"
        assign_files_or_directories_to_run "spec"
        expect(config.files_to_run).to contain_files("./spec/rspec/core/resources/a_spec.rb")
      end

      it "supports absolute path patterns", :failing_on_appveyor,
        :pending => false,
        :skip => (ENV['APPVEYOR'] ? "Failing on AppVeyor but :pending isn't working for some reason" : false) do
        dir = File.expand_path("../resources", __FILE__)
        config.pattern = File.join(dir, "**/*_spec.rb")
        assign_files_or_directories_to_run "spec"

        expect(config.files_to_run).to contain_files(
          "./spec/rspec/core/resources/acceptance/foo_spec.rb",
          "./spec/rspec/core/resources/a_spec.rb"
        )
      end

      it "supports relative path patterns for an alternate directory from `spec`" do
        Dir.chdir("./spec/rspec/core") do
          config.pattern = "resources/**/*_spec.rb"
          assign_files_or_directories_to_run "spec" # default dir

          expect(config.files_to_run).to contain_files(
            "resources/acceptance/foo_spec.rb",
            "resources/a_spec.rb"
          )
        end
      end

      it "does not attempt to treat the pattern relative to `.` if it uses `**` in the first path segment as that would cause it load specs from vendored gems" do
        Dir.chdir("./spec/rspec/core") do
          config.pattern = "**/*_spec.rb"
          assign_files_or_directories_to_run "spec" # default dir

          expect(config.files_to_run).to contain_files()
        end
      end

      it 'reloads when `files_or_directories_to_run` is reassigned' do
        config.pattern = "spec/**/a_spec.rb"
        config.files_or_directories_to_run = "empty_dir"

        expect {
          config.files_or_directories_to_run = "spec"
        }.to change { config.files_to_run }.
          to(a_file_collection("spec/rspec/core/resources/a_spec.rb"))
      end

      it 'attempts to load the provided file names' do
        assign_files_or_directories_to_run "path/to/some/file.rb"
        expect(config.files_to_run).to eq(["path/to/some/file.rb"])
      end

      it 'does not attempt to load a file at the `default_path`' do
        config.default_path = "path/to/dir"
        assign_files_or_directories_to_run "path/to/dir"
        expect(config.files_to_run).to eq([])
      end

      context "with <path>:<line_number>" do
        it "overrides inclusion filters set on config" do
          config.filter_run_including :foo => :bar
          assign_files_or_directories_to_run "path/to/file.rb:37"
          expect(inclusion_filter.size).to eq(1)
          expect(inclusion_filter[:locations].keys.first).to match(/path\/to\/file\.rb$/)
          expect(inclusion_filter[:locations].values.first).to eq([37])
        end

        it "overrides inclusion filters set before config" do
          config.force(:inclusion_filter => {:foo => :bar})
          assign_files_or_directories_to_run "path/to/file.rb:37"
          expect(inclusion_filter.size).to eq(1)
          expect(inclusion_filter[:locations].keys.first).to match(/path\/to\/file\.rb$/)
          expect(inclusion_filter[:locations].values.first).to eq([37])
        end

        it "clears exclusion filters set on config" do
          config.exclusion_filter = { :foo => :bar }
          assign_files_or_directories_to_run "path/to/file.rb:37"
          expect(exclusion_filter).to be_empty,
            "expected exclusion filter to be empty:\n#{exclusion_filter}"
        end

        it "clears exclusion filters set before config" do
          config.force(:exclusion_filter => { :foo => :bar })
          assign_files_or_directories_to_run "path/to/file.rb:37"
          expect(config.exclusion_filter).to be_empty,
            "expected exclusion filter to be empty:\n#{config.exclusion_filter}"
        end
      end

      context "with default pattern" do
        it "loads files named _spec.rb" do
          assign_files_or_directories_to_run "spec/rspec/core/resources"
          expect(config.files_to_run).to contain_files("spec/rspec/core/resources/a_spec.rb", "spec/rspec/core/resources/acceptance/foo_spec.rb")
        end

        it "loads files in Windows", :if => RSpec::Support::OS.windows? do
          assign_files_or_directories_to_run "C:\\path\\to\\project\\spec\\sub\\foo_spec.rb"
          expect(config.files_to_run).to contain_files("C:/path/to/project/spec/sub/foo_spec.rb")
        end

        it "loads files in Windows when directory is specified", :failing_on_appveyor, :if => RSpec::Support::OS.windows? do
          assign_files_or_directories_to_run "spec\\rspec\\core\\resources"
          expect(config.files_to_run).to contain_files("spec/rspec/core/resources/a_spec.rb")
        end

        it_behaves_like "handling symlinked directories when loading spec files" do
          def loaded_files
            assign_files_or_directories_to_run "spec"
            config.files_to_run
          end
        end
      end

      context "with default default_path" do
        it "loads files in the default path when run by rspec" do
          allow(config).to receive(:command) { 'rspec' }
          assign_files_or_directories_to_run []
          expect(config.files_to_run).not_to be_empty
        end

        it "loads files in the default path when run with DRB (e.g., spork)" do
          allow(config).to receive(:command) { 'spork' }
          allow(RSpec::Core::Runner).to receive(:running_in_drb?) { true }
          assign_files_or_directories_to_run []
          expect(config.files_to_run).not_to be_empty
        end

        it "does not load files in the default path when run by ruby" do
          allow(config).to receive(:command) { 'ruby' }
          assign_files_or_directories_to_run []
          expect(config.files_to_run).to be_empty
        end
      end

      def specify_consistent_ordering_of_files_to_run
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with('a') { true }
        globbed_files = nil
        allow(Dir).to receive(:[]).with(/^\{?a/) { globbed_files }
        allow(Dir).to receive(:[]).with(a_string_starting_with(Dir.getwd)) { [] }

        orderings = [
          %w[ a/1.rb a/2.rb a/3.rb ],
          %w[ a/2.rb a/1.rb a/3.rb ],
          %w[ a/3.rb a/2.rb a/1.rb ]
        ].map do |files|
          globbed_files = files
          yield
          config.files_to_run
        end

        expect(orderings.uniq.size).to eq(1)
      end

      context 'when the given directories match the pattern' do
        it 'orders the files in a consistent ordering, regardless of the underlying OS ordering' do
          specify_consistent_ordering_of_files_to_run do
            config.pattern = 'a/*.rb'
            assign_files_or_directories_to_run 'a'
          end
        end
      end

      context 'when the pattern is given relative to the given directories' do
        it 'orders the files in a consistent ordering, regardless of the underlying OS ordering' do
          specify_consistent_ordering_of_files_to_run do
            config.pattern = '*.rb'
            assign_files_or_directories_to_run 'a'
          end
        end
      end

      context 'when given multiple file paths' do
        it 'orders the files in a consistent ordering, regardless of the given order' do
          allow(File).to receive(:directory?) { false } # fake it into thinking these a full file paths

          files = ['a/b/c_spec.rb', 'c/b/a_spec.rb']
          assign_files_or_directories_to_run(*files)
          ordering_1 = config.files_to_run

          assign_files_or_directories_to_run(*files.reverse)
          ordering_2 = config.files_to_run

          expect(ordering_1).to eq(ordering_2)
        end
      end
    end

    describe "#pattern" do
      context "with single pattern" do
        before { config.pattern = "**/*_foo.rb" }

        it "loads all explicitly specified files, even those that do not match the pattern" do
          file_1 = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
          file_2 = File.expand_path(File.dirname(__FILE__) + "/resources/a_bar.rb")

          assign_files_or_directories_to_run file_1, file_2
          expect(config.files_to_run).to contain_exactly(file_1, file_2)
        end

        it "loads files in directories following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).to include("#{dir}/a_foo.rb")
        end

        it "does not load files in directories not following pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).not_to include("#{dir}/a_bar.rb")
        end

        it "ignores pattern if files are specified" do
          files = [
            File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb"),
            File.expand_path(File.dirname(__FILE__) + "/resources/a_spec.rb")
          ]
          assign_files_or_directories_to_run(files)
          expect(config.files_to_run).to match_array(files)
        end
      end

      context "with multiple patterns" do
        it "supports comma separated values" do
          config.pattern = "**/*_foo.rb,**/*_bar.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).to include("#{dir}/a_bar.rb")
        end

        it "supports comma separated values with spaces" do
          config.pattern = "**/*_foo.rb, **/*_bar.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).to include("#{dir}/a_bar.rb")
        end

        it "supports curly braces glob syntax" do
          config.pattern = "**/*_{foo,bar}.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).to include("#{dir}/a_bar.rb")
        end
      end

      context "after files have already been loaded" do
        it 'warns that it will have no effect' do
          expect_warning_with_call_site(__FILE__, __LINE__ + 2, /has no effect/)
          config.load_spec_files
          config.pattern = "rspec/**/*.spec"
        end

        it 'does not warn if reset is called after load_spec_files' do
          config.load_spec_files
          config.reset
          expect(RSpec).to_not receive(:warning)
          config.pattern = "rspec/**/*.spec"
        end
      end

      context "after `files_to_run` has been accessed but before files have been loaded" do
        it 'still takes affect' do
          file = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
          assign_files_or_directories_to_run File.dirname(file)
          expect(config.files_to_run).not_to include(file)
          config.pattern = "**/*_foo.rb"
          expect(config.files_to_run).to include(file)
        end
      end
    end

    describe "#exclude_pattern" do
      context "with single pattern" do
        before { config.exclude_pattern = "**/*_foo.rb" }

        it "does not load files in directories following exclude pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).not_to include("#{dir}/a_foo.rb")
        end

        it "loads files in directories not following exclude pattern" do
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).to include("#{dir}/a_spec.rb")
        end

        it "ignores exclude_pattern if files are specified" do
          files = [
            File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb"),
            File.expand_path(File.dirname(__FILE__) + "/resources/a_spec.rb")
          ]
          assign_files_or_directories_to_run(files)
          expect(config.files_to_run).to match_array(files)
        end
      end

      context "with multiple patterns" do
        it "supports comma separated values" do
          config.exclude_pattern = "**/*_foo.rb,**/*_bar.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).not_to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).not_to include("#{dir}/a_bar.rb")
        end

        it "supports comma separated values with spaces" do
          config.exclude_pattern = "**/*_foo.rb, **/*_bar.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).not_to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).not_to include("#{dir}/a_bar.rb")
        end

        it "supports curly braces glob syntax" do
          config.exclude_pattern = "**/*_{foo,bar}.rb"
          dir = File.expand_path(File.dirname(__FILE__) + "/resources")
          assign_files_or_directories_to_run dir
          expect(config.files_to_run).not_to include("#{dir}/a_foo.rb")
          expect(config.files_to_run).not_to include("#{dir}/a_bar.rb")
        end
      end

      context "after files have already been loaded" do
        it 'warns that it will have no effect' do
          expect_warning_with_call_site(__FILE__, __LINE__ + 2, /has no effect/)
          config.load_spec_files
          config.exclude_pattern = "rspec/**/*.spec"
        end

        it 'does not warn if reset is called after load_spec_files' do
          config.load_spec_files
          config.reset
          expect(RSpec).to_not receive(:warning)
          config.exclude_pattern = "rspec/**/*.spec"
        end
      end

      context "after `files_to_run` has been accessed but before files have been loaded" do
        it 'still takes affect' do
          config.pattern = "**/*.rb"
          file = File.expand_path(File.dirname(__FILE__) + "/resources/a_foo.rb")
          assign_files_or_directories_to_run File.dirname(file)
          expect(config.files_to_run).to include(file)
          config.exclude_pattern = "**/*_foo.rb"
          expect(config.files_to_run).not_to include(file)
        end
      end
    end

    describe "path with line number" do
      it "assigns the line number as a location filter" do
        assign_files_or_directories_to_run "path/to/a_spec.rb:37"
        expect(inclusion_filter).to eq({:locations => {File.expand_path("path/to/a_spec.rb") => [37]}})
      end
    end

    context "with full_description set" do
      it "overrides filters" do
        config.filter_run :focused => true
        config.full_description = "foo"
        expect(inclusion_filter).not_to have_key(:focused)
      end

      it 'is possible to access the full description regular expression' do
        config.full_description = "foo"
        expect(config.full_description).to eq(/foo/)
      end
    end

    context "without full_description having been set" do
      it 'returns nil from #full_description' do
        expect(config.full_description).to eq nil
      end
    end

    context "with line number" do
      it "assigns the file and line number as a location filter" do
        assign_files_or_directories_to_run "path/to/a_spec.rb:37"
        expect(inclusion_filter).to eq({:locations => {File.expand_path("path/to/a_spec.rb") => [37]}})
      end

      it "assigns multiple files with line numbers as location filters" do
        assign_files_or_directories_to_run "path/to/a_spec.rb:37", "other_spec.rb:44"
        expect(inclusion_filter).to eq({:locations => {File.expand_path("path/to/a_spec.rb") => [37],
                                                File.expand_path("other_spec.rb") => [44]}})
      end

      it "assigns files with multiple line numbers as location filters" do
        assign_files_or_directories_to_run "path/to/a_spec.rb:37", "path/to/a_spec.rb:44"
        expect(inclusion_filter).to eq({:locations => {File.expand_path("path/to/a_spec.rb") => [37, 44]}})
      end
    end

    context "with multiple line numbers" do
      it "assigns the file and line numbers as a location filter" do
        assign_files_or_directories_to_run "path/to/a_spec.rb:1:3:5:7"
        expect(inclusion_filter).to eq({:locations => {File.expand_path("path/to/a_spec.rb") => [1,3,5,7]}})
      end
    end

    it "assigns the example name as the filter on description" do
      config.full_description = "foo"
      expect(inclusion_filter).to eq({:full_description => /foo/})
    end

    it "assigns the example names as the filter on description if description is an array" do
      config.full_description = [ "foo", "bar" ]
      expect(inclusion_filter).to eq({:full_description => Regexp.union(/foo/, /bar/)})
    end

    it 'is possible to access the full description regular expression' do
      config.full_description = "foo","bar"
      expect(config.full_description).to eq Regexp.union(/foo/,/bar/)
    end

    describe "#default_path" do
      it 'defaults to "spec"' do
        expect(config.default_path).to eq('spec')
      end
    end

    describe "#include" do
      include_examples "warning of deprecated `:example_group` during filtering configuration", :include, Enumerable

      module InstanceLevelMethods
        def you_call_this_a_blt?
          "egad man, where's the mayo?!?!?"
        end
      end

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.include(InstanceLevelMethods, *args)
          config.instance_variable_get(:@include_modules).items.last.last
        end
      end

      context "with no filter" do
        it "includes the given module into each example group" do
          RSpec.configure do |c|
            c.include(InstanceLevelMethods)
          end

          group = RSpec.describe('does like, stuff and junk', :magic_key => :include) { }
          expect(group).not_to respond_to(:you_call_this_a_blt?)
          expect(group.new.you_call_this_a_blt?).to eq("egad man, where's the mayo?!?!?")
        end
      end

      context "with a filter" do
        it "includes the given module into each matching example group" do
          RSpec.configure do |c|
            c.include(InstanceLevelMethods, :magic_key => :include)
          end

          group = RSpec.describe('does like, stuff and junk', :magic_key => :include) { }
          expect(group).not_to respond_to(:you_call_this_a_blt?)
          expect(group.new.you_call_this_a_blt?).to eq("egad man, where's the mayo?!?!?")
        end
      end
    end

    describe "#extend" do
      include_examples "warning of deprecated `:example_group` during filtering configuration", :extend, Enumerable

      module ThatThingISentYou
        def that_thing
        end
      end

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.extend(ThatThingISentYou, *args)
          config.instance_variable_get(:@extend_modules).items.last.last
        end
      end

      it "extends the given module into each matching example group" do
        RSpec.configure do |c|
          c.extend(ThatThingISentYou, :magic_key => :extend)
        end

        group = RSpec.describe(ThatThingISentYou, :magic_key => :extend) { }
        expect(group).to respond_to(:that_thing)
      end

    end

    describe "#prepend", :if => RSpec::Support::RubyFeatures.module_prepends_supported? do
      include_examples "warning of deprecated `:example_group` during filtering configuration", :prepend, Enumerable

      module SomeRandomMod
        def foo
          "foobar"
        end
      end

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.prepend(SomeRandomMod, *args)
          config.instance_variable_get(:@prepend_modules).items.last.last
        end
      end

      context "with no filter" do
        it "prepends the given module into each example group" do
          RSpec.configure do |c|
            c.prepend(SomeRandomMod)
          end

          group = RSpec.describe('yo') { }
          expect(group.new.foo).to eq("foobar")
        end
      end

      context "with a filter" do
        it "prepends the given module into each matching example group" do
          RSpec.configure do |c|
            c.prepend(SomeRandomMod, :magic_key => :include)
          end

          group = RSpec.describe('yo', :magic_key => :include) { }
          expect(group.new.foo).to eq("foobar")
        end
      end

    end

    describe "#run_all_when_everything_filtered?" do

      it "defaults to false" do
        expect(config.run_all_when_everything_filtered?).to be_falsey
      end

      it "can be queried with question method" do
        config.run_all_when_everything_filtered = true
        expect(config.run_all_when_everything_filtered?).to be_truthy
      end
    end

    describe "#color=" do
      context "given true" do
        before { config.color = true }

        context "with config.tty? and output.tty?" do
          it "sets color_enabled?" do
            output = StringIO.new
            config.output_stream = output

            config.tty = true
            allow(config.output_stream).to receive_messages :tty? => true

            expect(config.color_enabled?).to be_truthy
            expect(config.color_enabled?(output)).to be_truthy
          end
        end

        context "with config.tty? and !output.tty?" do
          it "sets color_enabled?" do
            output = StringIO.new
            config.output_stream = output

            config.tty = true
            allow(config.output_stream).to receive_messages :tty? => false

            expect(config.color_enabled?).to be_truthy
            expect(config.color_enabled?(output)).to be_truthy
          end
        end

        context "with config.tty? and !output.tty?" do
          it "does not set color_enabled?" do
            output = StringIO.new
            config.output_stream = output

            config.tty = false
            allow(config.output_stream).to receive_messages :tty? => true

            expect(config.color_enabled?).to be_truthy
            expect(config.color_enabled?(output)).to be_truthy
          end
        end

        context "with !config.tty? and !output.tty?" do
          it "does not set color_enabled?" do
            output = StringIO.new
            config.output_stream = output

            config.tty = false
            allow(config.output_stream).to receive_messages :tty? => false

            expect(config.color_enabled?).to be_falsey
            expect(config.color_enabled?(output)).to be_falsey
          end
        end
      end

      context "on windows" do
        before do
          @original_host  = RbConfig::CONFIG['host_os']
          RbConfig::CONFIG['host_os'] = 'mingw'
          allow(config).to receive(:require)
        end

        after do
          RbConfig::CONFIG['host_os'] = @original_host
        end

        context "with ANSICON available" do
          around(:each) { |e| with_env_vars('ANSICON' => 'ANSICON', &e) }

          it "enables colors" do
            config.output_stream = StringIO.new
            allow(config.output_stream).to receive_messages :tty? => true
            config.color = true
            expect(config.color).to be_truthy
          end

          it "leaves output stream intact" do
            config.output_stream = $stdout
            allow(config).to receive(:require) do |what|
              config.output_stream = 'foo' if what =~ /Win32/
            end
            config.color = true
            expect(config.output_stream).to eq($stdout)
          end
        end

        context "with ANSICON NOT available" do
          around { |e| without_env_vars('ANSICON', &e) }

          before do
            allow_warning
          end

          it "warns to install ANSICON" do
            allow(config).to receive(:require) { raise LoadError }
            expect_warning_with_call_site(__FILE__, __LINE__ + 1, /You must use ANSICON/)
            config.color = true
          end

          it "sets color to false" do
            allow(config).to receive(:require) { raise LoadError }
            config.color = true
            expect(config.color).to be_falsey
          end
        end
      end

      it "prefers incoming cli_args" do
        config.output_stream = StringIO.new
        allow(config.output_stream).to receive_messages :tty? => true
        config.force :color => true
        config.color = false
        expect(config.color).to be_truthy
      end
    end

    %w[formatter= add_formatter].each do |config_method|
      describe "##{config_method}" do
        it "delegates to formatters#add" do
          expect(config.formatter_loader).to receive(:add).with('these','options')
          config.send(config_method,'these','options')
        end
      end
    end

    describe "#formatters" do
      it "returns a dup of the formatter_loader formatters" do
        config.add_formatter 'doc'
        config.formatters.clear
        expect(config.formatters).to_not eq []
      end
    end

    describe "#default_formatter" do
      it 'defaults to `progress`' do
        expect(config.default_formatter).to eq('progress')
      end

      it 'remembers changes' do
        config.default_formatter = 'doc'
        expect(config.default_formatter).to eq('doc')
      end

      context 'when another formatter has been set' do
        it 'does not get used' do
          config.default_formatter = 'doc'
          config.add_formatter 'progress'

          expect(used_formatters).to include(an_instance_of Formatters::ProgressFormatter)
          expect(used_formatters).not_to include(an_instance_of Formatters::DocumentationFormatter)
        end
      end

      context 'when no other formatter has been set' do
        it 'gets used' do
          config.default_formatter = 'doc'

          expect(used_formatters).not_to include(an_instance_of Formatters::ProgressFormatter)
          expect(used_formatters).to include(an_instance_of Formatters::DocumentationFormatter)
        end
      end

      context 'using a legacy formatter as default' do
        # Generating warnings during formatter initialisation triggers the
        # ProxyReporter code path.
        it 'remembers changes' do
          legacy_formatter = Class.new

          config = RSpec.configuration
          config.default_formatter = legacy_formatter
          config.reporter
          expect(config.default_formatter).to eq(legacy_formatter)
        end
      end

      def used_formatters
        config.reporter # to force freezing of formatters
        config.formatters
      end
    end

    describe "#filter_run_including" do
      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.filter_run_including(*args)
          config.inclusion_filter.rules
        end
      end

      include_examples "warning of deprecated `:example_group` during filtering configuration", :filter_run_including

      it "sets the filter with a hash" do
        config.filter_run_including :foo => true
        expect(inclusion_filter).to eq( {:foo => true} )
      end

      it "sets the filter with a symbol" do
        config.filter_run_including :foo
        expect(inclusion_filter).to eq( {:foo => true} )
      end

      it "merges with existing filters" do
        config.filter_run_including :foo => true
        config.filter_run_including :bar => false
        expect(inclusion_filter).to eq( {:foo => true, :bar => false} )
      end
    end

    describe "#filter_run_excluding" do
      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.filter_run_excluding(*args)
          config.exclusion_filter.rules
        end
      end

      include_examples "warning of deprecated `:example_group` during filtering configuration", :filter_run_excluding

      it "sets the filter" do
        config.filter_run_excluding :foo => true
        expect(exclusion_filter).to eq( {:foo => true} )
      end

      it "sets the filter using a symbol" do
        config.filter_run_excluding :foo
        expect(exclusion_filter).to eq( {:foo => true} )
      end

      it "merges with existing filters" do
        config.filter_run_excluding :foo => true
        config.filter_run_excluding :bar => false
        expect(exclusion_filter).to eq( {:foo => true, :bar => false} )
      end
    end

    shared_examples_for "a spec filter" do |type|
      describe "##{type}" do
        it "returns {} even if set to nil" do
          config.send("#{type}=", nil)
          expect(send(type)).to eq({})
        end
      end

      describe "##{type}=" do
        it "treats symbols as hash keys with true values when told to" do
          config.send("#{type}=", :foo)
          expect(send(type)).to eq( {:foo => true} )
        end

        it "overrides any #{type} set on the command line or in configuration files" do
          config.force(type => { :foo => :bar })
          config.send("#{type}=", {:want => :this})
          expect(send(type)).to eq( {:want => :this} )
        end

        include_examples "warning of deprecated `:example_group` during filtering configuration", :"#{type}="
      end
    end
    it_behaves_like "a spec filter", :inclusion_filter
    it_behaves_like "a spec filter", :exclusion_filter

    describe "#treat_symbols_as_metadata_keys_with_true_values=" do
      it 'is deprecated' do
        expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
        config.treat_symbols_as_metadata_keys_with_true_values = true
      end
    end

    describe "#full_backtrace=" do
      it "doesn't impact other instances of config" do
        config_1 = Configuration.new
        config_2 = Configuration.new

        config_1.full_backtrace = true
        expect(config_2.full_backtrace?).to be_falsey
      end
    end

    describe "#backtrace_exclusion_patterns=" do
      it "actually receives the new filter values" do
        config = Configuration.new
        config.backtrace_exclusion_patterns = [/.*/]
        expect(config.backtrace_formatter.exclude? "this").to be_truthy
      end
    end

    describe 'full_backtrace' do
      it 'returns true when backtrace patterns is empty' do
        config.backtrace_exclusion_patterns = []
        expect(config.full_backtrace?).to eq true
      end

      it 'returns false when backtrace patterns isnt empty' do
        config.backtrace_exclusion_patterns = [:lib]
        expect(config.full_backtrace?).to eq false
      end
    end

    describe "#backtrace_exclusion_patterns" do
      it "can be appended to" do
        config = Configuration.new
        config.backtrace_exclusion_patterns << /.*/
        expect(config.backtrace_formatter.exclude? "this").to be_truthy
      end
    end

    describe "#filter_gems_from_backtrace" do
      def exclude?(line)
        config.backtrace_formatter.exclude?(line)
      end

      it 'filters the named gems from the backtrace' do
        line_1 = "/Users/myron/.gem/ruby/2.1.1/gems/foo-1.6.3.1/foo.rb:13"
        line_2 = "/Users/myron/.gem/ruby/2.1.1/gems/bar-1.6.3.1/bar.rb:13"

        expect {
          config.filter_gems_from_backtrace "foo", "bar"
        }.to change { exclude?(line_1) }.from(false).to(true).
         and change { exclude?(line_2) }.from(false).to(true)
      end
    end

    describe "#libs=" do
      it "adds directories to the LOAD_PATH" do
        expect($LOAD_PATH).to receive(:unshift).with("a/dir")
        config.libs = ["a/dir"]
      end
    end

    describe "libs" do
      it 'records paths added to the load path' do
        config.libs = ["a/dir"]
        expect(config.libs).to eq ["a/dir"]
      end
    end

    describe "#define_derived_metadata" do
      include_examples "warning of deprecated `:example_group` during filtering configuration", :define_derived_metadata

      it 'allows the provided block to mutate example group metadata' do
        RSpec.configuration.define_derived_metadata do |metadata|
          metadata[:reverse_description] = metadata[:description].reverse
        end

        group = RSpec.describe("My group")
        expect(group.metadata).to include(:description => "My group", :reverse_description => "puorg yM")
      end

      it 'allows the provided block to mutate example metadata' do
        RSpec.configuration.define_derived_metadata do |metadata|
          metadata[:reverse_description] = metadata[:description].reverse
        end

        ex = RSpec.describe("My group").example("foo")
        expect(ex.metadata).to include(:description => "foo", :reverse_description => "oof")
      end

      it 'allows multiple configured blocks to be applied, in order of definition' do
        RSpec.configure do |c|
          c.define_derived_metadata { |m| m[:b1_desc] = m[:description] + " (block 1)" }
          c.define_derived_metadata { |m| m[:b2_desc] = m[:b1_desc]     + " (block 2)" }
        end

        group = RSpec.describe("bar")
        expect(group.metadata).to include(:b1_desc => "bar (block 1)", :b2_desc => "bar (block 1) (block 2)")
      end

      it "derives metadata before the group or example blocks are eval'd so their logic can depend on the derived metadata" do
        RSpec.configure do |c|
          c.define_derived_metadata(:foo) do |metadata|
            metadata[:bar] = "bar"
          end
        end

        group_bar_value = example_bar_value = nil

        RSpec.describe "Group", :foo do
          group_bar_value = metadata[:bar]
          example_bar_value = example("ex", :foo).metadata[:bar]
        end

        expect(group_bar_value).to eq("bar")
        expect(example_bar_value).to eq("bar")
      end

      context "when passed a metadata filter" do
        it 'only applies to the groups and examples that match that filter' do
          RSpec.configure do |c|
            c.define_derived_metadata(:apply => true) do |metadata|
              metadata[:reverse_description] = metadata[:description].reverse
            end
          end

          g1 = RSpec.describe("G1", :apply)
          g2 = RSpec.describe("G2")
          e1 = g1.example("E1")
          e2 = g2.example("E2", :apply)
          e3 = g2.example("E3")

          expect(g1.metadata).to include(:reverse_description => "1G")
          expect(g2.metadata).not_to include(:reverse_description)

          expect(e1.metadata).to include(:reverse_description => "1E")
          expect(e2.metadata).to include(:reverse_description => "2E")
          expect(e3.metadata).not_to include(:reverse_description)
        end

        it 'applies if any of multiple filters apply (to align with module inclusion semantics)' do
          RSpec.configure do |c|
            c.define_derived_metadata(:a => 1, :b => 2) do |metadata|
              metadata[:reverse_description] = metadata[:description].reverse
            end
          end

          g1 = RSpec.describe("G1", :a => 1)
          g2 = RSpec.describe("G2", :b => 2)
          g3 = RSpec.describe("G3", :c => 3)

          expect(g1.metadata).to include(:reverse_description => "1G")
          expect(g2.metadata).to include(:reverse_description => "2G")
          expect(g3.metadata).not_to include(:reverse_description)
        end

        it 'allows a metadata filter to be passed as a raw symbol' do
          RSpec.configure do |c|
            c.define_derived_metadata(:apply) do |metadata|
              metadata[:reverse_description] = metadata[:description].reverse
            end
          end

          g1 = RSpec.describe("G1", :apply)
          g2 = RSpec.describe("G2")

          expect(g1.metadata).to include(:reverse_description => "1G")
          expect(g2.metadata).not_to include(:reverse_description)
        end
      end
    end

    describe "#add_setting" do
      describe "with no modifiers" do
        context "with no additional options" do
          before do
            config.add_setting :custom_option
          end

          it "defaults to nil" do
            expect(config.custom_option).to be_nil
          end

          it "adds a predicate" do
            expect(config.custom_option?).to be_falsey
          end

          it "can be overridden" do
            config.custom_option = "a value"
            expect(config.custom_option).to eq("a value")
          end
        end

        context "with :default => 'a value'" do
          before do
            config.add_setting :custom_option, :default => 'a value'
          end

          it "defaults to 'a value'" do
            expect(config.custom_option).to eq("a value")
          end

          it "returns true for the predicate" do
            expect(config.custom_option?).to be_truthy
          end

          it "can be overridden with a truthy value" do
            config.custom_option = "a new value"
            expect(config.custom_option).to eq("a new value")
          end

          it "can be overridden with nil" do
            config.custom_option = nil
            expect(config.custom_option).to eq(nil)
          end

          it "can be overridden with false" do
            config.custom_option = false
            expect(config.custom_option).to eq(false)
          end
        end
      end

      context "with :alias_with => " do
        before do
          config.add_setting :custom_option, :alias_with => :another_custom_option
        end

        it "delegates the getter to the other option" do
          config.another_custom_option = "this value"
          expect(config.custom_option).to eq("this value")
        end

        it "delegates the setter to the other option" do
          config.custom_option = "this value"
          expect(config.another_custom_option).to eq("this value")
        end

        it "delegates the predicate to the other option" do
          config.custom_option = true
          expect(config.another_custom_option?).to be_truthy
        end
      end
    end

    describe "#configure_group" do
      it "extends with 'extend'" do
        mod = Module.new
        group = RSpec.describe("group", :foo => :bar)

        config.extend(mod, :foo => :bar)
        config.configure_group(group)
        expect(group).to be_a(mod)
      end

      it "extends with 'module'" do
        mod = Module.new
        group = RSpec.describe("group", :foo => :bar)

        config.include(mod, :foo => :bar)
        config.configure_group(group)
        expect(group.included_modules).to include(mod)
      end

      it "requires only one matching filter" do
        mod = Module.new
        group = RSpec.describe("group", :foo => :bar)

        config.include(mod, :foo => :bar, :baz => :bam)
        config.configure_group(group)
        expect(group.included_modules).to include(mod)
      end

      module IncludeExtendOrPrependMeOnce
        def self.included(host)
          raise "included again" if host.instance_methods.include?(:foobar)
          host.class_exec { def foobar; end }
        end

        def self.extended(host)
          raise "extended again" if host.respond_to?(:foobar)
          def host.foobar; end
        end

        def self.prepended(host)
          raise "prepended again" if host.instance_methods.include?(:barbaz)
          host.class_exec { def barbaz; end }
        end
      end

      it "doesn't include a module when already included in ancestor" do
        config.include(IncludeExtendOrPrependMeOnce, :foo => :bar)

        group = RSpec.describe("group", :foo => :bar)
        child = group.describe("child")

        config.configure_group(group)
        config.configure_group(child)
      end

      it "doesn't extend when ancestor is already extended with same module" do
        config.extend(IncludeExtendOrPrependMeOnce, :foo => :bar)

        group = RSpec.describe("group", :foo => :bar)
        child = group.describe("child")

        config.configure_group(group)
        config.configure_group(child)
      end

      it "doesn't prepend a module when already present in ancestor chain",
        :if => RSpec::Support::RubyFeatures.module_prepends_supported? do
        config.prepend(IncludeExtendOrPrependMeOnce, :foo => :bar)

        group = RSpec.describe("group", :foo => :bar)
        child = group.describe("child")

        config.configure_group(group)
        config.configure_group(child)
      end
    end

    describe "#alias_example_group_to" do
      after do
        RSpec::Core::DSL.example_group_aliases.delete(:my_group_method)

        RSpec.module_exec do
          class << self
            undef :my_group_method if method_defined? :my_group_method
          end
        end

        RSpec::Core::ExampleGroup.module_exec do
          class << self
            undef :my_group_method if method_defined? :my_group_method
          end
        end
      end

      it_behaves_like "metadata hash builder" do
        def metadata_hash(*args)
          config.alias_example_group_to :my_group_method, *args
          group = ExampleGroup.my_group_method("a group")
          group.metadata
        end
      end

      it "allows adding additional metadata" do
        config.alias_example_group_to :my_group_method, { :some => "thing" }
        group = ExampleGroup.my_group_method("a group", :another => "thing")
        expect(group.metadata).to include(:some => "thing", :another => "thing")
      end

      it "passes `nil` as the description arg when no args are given" do
        config.alias_example_group_to :my_group_method, { :some => "thing" }
        group = ExampleGroup.my_group_method

        expect(group.metadata).to include(
          :description_args => [nil],
          :description => "",
          :some => "thing"
        )
      end

      context 'when the aliased method is used' do
        it_behaves_like "metadata hash builder" do
          def metadata_hash(*args)
            config.alias_example_group_to :my_group_method
            group = ExampleGroup.my_group_method("a group", *args)
            group.metadata
          end
        end
      end
    end

    describe "#alias_example_to" do
      it_behaves_like "metadata hash builder" do
        after do
          RSpec::Core::ExampleGroup.module_exec do
            class << self
              undef :my_example_method if method_defined? :my_example_method
            end
          end
        end
        def metadata_hash(*args)
          config.alias_example_to :my_example_method, *args
          group = RSpec.describe("group")
          example = group.my_example_method("description")
          example.metadata
        end
      end
    end

    describe "#reset" do
      it "clears the reporter" do
        expect(config.reporter).not_to be_nil
        config.reset
        expect(config.instance_variable_get("@reporter")).to be_nil
      end

      it "clears the formatters" do
        config.add_formatter "doc"
        config.reset
        expect(config.formatters).to be_empty
      end
    end

    describe "#force" do
      context "for ordering options" do
        let(:list) { [1, 2, 3, 4] }
        let(:ordering_strategy) { config.ordering_registry.fetch(:global) }
        let(:rng) { RSpec::Core::RandomNumberGenerator.new config.seed }
        let(:shuffled) { Ordering::Random.new(config).shuffle list, rng }

        specify "CLI `--order defined` takes precedence over `config.order = rand`" do
          config.force :order => "defined"
          config.order = "rand"

          expect(ordering_strategy.order(list)).to eq([1, 2, 3, 4])
        end

        specify "CLI `--order rand:37` takes precedence over `config.order = defined`" do
          config.force :order => "rand:37"
          config.order = "defined"

          expect(ordering_strategy.order(list)).to eq(shuffled)
        end

        specify "CLI `--seed 37` forces order and seed" do
          config.force :seed => 37
          config.order = "defined"
          config.seed  = 145

          expect(ordering_strategy.order(list)).to eq(shuffled)
          expect(config.seed).to eq(37)
        end

        specify "CLI `--order defined` takes precedence over `config.register_ordering(:global)`" do
          config.force :order => "defined"
          config.register_ordering(:global, &:reverse)
          expect(ordering_strategy.order(list)).to eq([1, 2, 3, 4])
        end
      end

      it "forces 'false' value" do
        config.add_setting :custom_option
        config.custom_option = true
        expect(config.custom_option?).to be_truthy
        config.force :custom_option => false
        expect(config.custom_option?).to be_falsey
        config.custom_option = true
        expect(config.custom_option?).to be_falsey
      end
    end

    describe '#seed' do
      it 'returns the seed as an int' do
        config.seed = '123'
        expect(config.seed).to eq(123)
      end
    end

    describe "#seed_used?" do
      def use_seed_on(registry)
        registry.fetch(:random).order([1, 2])
      end

      it 'returns false if neither ordering registry used the seed' do
        expect(config.seed_used?).to be false
      end

      it 'returns true if the ordering registry used the seed' do
        use_seed_on(config.ordering_registry)
        expect(config.seed_used?).to be true
      end
    end

    describe '#order=' do
      context 'given "random"' do
        before do
          config.seed = 7654
          config.order = 'random'
        end

        it 'does not change the seed' do
          expect(config.seed).to eq(7654)
        end

        it 'sets up random ordering' do
          allow(RSpec).to receive_messages(:configuration => config)
          global_ordering = config.ordering_registry.fetch(:global)
          expect(global_ordering).to be_an_instance_of(Ordering::Random)
        end
      end

      context 'given "random:123"' do
        before { config.order = 'random:123' }

        it 'sets seed to 123' do
          expect(config.seed).to eq(123)
        end

        it 'sets up random ordering' do
          allow(RSpec).to receive_messages(:configuration => config)
          global_ordering = config.ordering_registry.fetch(:global)
          expect(global_ordering).to be_an_instance_of(Ordering::Random)
        end
      end

      context 'given "defined"' do
        before do
          config.order = 'rand:123'
          config.order = 'defined'
        end

        it "does not change the seed" do
          expect(config.seed).to eq(123)
        end

        it 'clears the random ordering' do
          allow(RSpec).to receive_messages(:configuration => config)
          list = [1, 2, 3, 4]
          ordering_strategy = config.ordering_registry.fetch(:global)
          expect(ordering_strategy.order(list)).to eq([1, 2, 3, 4])
        end
      end
    end

    describe "#register_ordering" do
      def register_reverse_ordering
        config.register_ordering(:reverse, &:reverse)
      end

      it 'stores the ordering for later use' do
        register_reverse_ordering

        list = [1, 2, 3]
        strategy = config.ordering_registry.fetch(:reverse)
        expect(strategy).to be_a(Ordering::Custom)
        expect(strategy.order(list)).to eq([3, 2, 1])
      end

      it 'can register an ordering object' do
        strategy = Object.new
        def strategy.order(list)
          list.reverse
        end

        config.register_ordering(:reverse, strategy)
        list = [1, 2, 3]
        fetched = config.ordering_registry.fetch(:reverse)
        expect(fetched).to be(strategy)
        expect(fetched.order(list)).to eq([3, 2, 1])
      end
    end

    describe '#warnings' do
      around do |example|
        original_setting = $VERBOSE
        example.run
        $VERBOSE = original_setting
      end

      it "sets verbose to true when true" do
        config.warnings = true
        expect($VERBOSE).to eq true
      end

      it "sets verbose to false when true" do
        config.warnings = false
        expect($VERBOSE).to eq false
      end

      it 'returns the verbosity setting' do
        config.warnings = true
        expect(config.warnings?).to eq true

        config.warnings = false
        expect(config.warnings?).to eq false
      end

      it 'is loaded from config by #force' do
        config.force :warnings => true
        expect($VERBOSE).to eq true
      end
    end

    describe "#raise_errors_for_deprecations!" do
      it 'causes deprecations to raise errors rather than printing to the deprecation stream' do
        config.deprecation_stream = stream = StringIO.new
        config.raise_errors_for_deprecations!

        expect {
          config.reporter.deprecation(:deprecated => "foo", :call_site => "foo.rb:1")
        }.to raise_error(RSpec::Core::DeprecationError, /foo is deprecated/)

        expect(stream.string).to eq("")
      end
    end

    describe "#expose_current_running_example_as" do
      before { stub_const(Configuration::ExposeCurrentExample.name, Module.new) }

      it 'exposes the current example via the named method' do
        RSpec.configuration.expose_current_running_example_as :the_example
        RSpec.configuration.expose_current_running_example_as :another_example_helper

        value_1 = value_2 = nil

        RSpec.describe "Group" do
          it "works" do
            value_1 = the_example
            value_2 = another_example_helper
          end
        end.run

        expect(value_1).to be_an(RSpec::Core::Example)
        expect(value_1.description).to eq("works")
        expect(value_2).to be(value_1)
      end
    end

    describe '#disable_monkey_patching!' do
      let!(:config) { RSpec.configuration }
      let!(:expectations) { RSpec::Expectations }
      let!(:mocks) { RSpec::Mocks }

      def in_fully_monkey_patched_rspec_environment
        in_sub_process do
          config.expose_dsl_globally = true
          mocks.configuration.syntax = [:expect, :should]
          mocks.configuration.patch_marshal_to_support_partial_doubles = true
          expectations.configuration.syntax = [:expect, :should]

          yield
        end
      end

      it 'stops exposing the DSL methods globally' do
        in_fully_monkey_patched_rspec_environment do
          mod = Module.new
          expect {
            config.disable_monkey_patching!
          }.to change { mod.respond_to?(:describe) }.from(true).to(false)
        end
      end

      it 'stops using should syntax for expectations' do
        in_fully_monkey_patched_rspec_environment do
          obj = Object.new
          config.expect_with :rspec
          expect {
            config.disable_monkey_patching!
          }.to change { obj.respond_to?(:should) }.from(true).to(false)
        end
      end

      it 'stops using should syntax for mocks' do
        in_fully_monkey_patched_rspec_environment do
          obj = Object.new
          config.mock_with :rspec
          expect {
            config.disable_monkey_patching!
          }.to change { obj.respond_to?(:should_receive) }.from(true).to(false)
        end
      end

      it 'stops patching of Marshal' do
        in_fully_monkey_patched_rspec_environment do
          expect {
            config.disable_monkey_patching!
          }.to change { Marshal.respond_to?(:dump_with_rspec_mocks) }.from(true).to(false)
        end
      end

      context 'when user did not configure mock framework' do
        def emulate_not_configured_mock_framework
          in_fully_monkey_patched_rspec_environment do
            allow(config).to receive(:rspec_mocks_loaded?).and_return(false, true)
            config.instance_variable_set :@mock_framework, nil
            ExampleGroup.send :remove_class_variable, :@@example_groups_configured

            yield
          end
        end

        it 'disables monkey patching after example groups being configured' do
          emulate_not_configured_mock_framework do
            obj = Object.new
            config.disable_monkey_patching!

            expect {
              ExampleGroup.ensure_example_groups_are_configured
            }.to change { obj.respond_to?(:should_receive) }.from(true).to(false)
          end
        end
      end

      context 'when user did not configure expectation framework' do
        def emulate_not_configured_expectation_framework
          in_fully_monkey_patched_rspec_environment do
            allow(config).to receive(:rspec_expectations_loaded?).and_return(false, true)
            config.instance_variable_set :@expectation_frameworks, []
            ExampleGroup.send :remove_class_variable, :@@example_groups_configured

            yield
          end
        end

        it 'disables monkey patching after example groups being configured' do
          emulate_not_configured_expectation_framework do
            obj = Object.new
            config.disable_monkey_patching!

            expect {
              ExampleGroup.ensure_example_groups_are_configured
            }.to change { obj.respond_to?(:should) }.from(true).to(false)
          end
        end
      end
    end

    describe 'recording spec start time (for measuring load)' do
      it 'returns a time' do
        expect(config.start_time).to be_an_instance_of ::Time
      end

      it 'is configurable' do
        config.start_time = 42
        expect(config.start_time).to eq 42
      end
    end

    describe "hooks" do
      include_examples "warning of deprecated `:example_group` during filtering configuration", :before, :each
    end

    # assigns files_or_directories_to_run and triggers post-processing
    # via `files_to_run`.
    def assign_files_or_directories_to_run(*value)
      config.files_or_directories_to_run = value
      config.files_to_run
    end
  end
end
