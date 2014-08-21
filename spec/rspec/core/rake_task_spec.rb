require "spec_helper"
require "rspec/core/rake_task"
require 'tempfile'

module RSpec::Core
  RSpec.describe RakeTask do
    let(:task) { RakeTask.new }

    def ruby
      FileUtils::RUBY
    end

    def spec_command
      task.__send__(:spec_command)
    end

    context "with a name passed to the constructor" do
      let(:task) { RakeTask.new(:task_name) }

      it "correctly sets the name" do
        expect(task.name).to eq :task_name
      end
    end

    context "with args passed to the rake task" do
      it "correctly passes along task arguments" do
        task = RakeTask.new(:rake_task_args, :files) do |t, args|
          expect(args[:files]).to eq "first_spec.rb"
        end

        expect(task).to receive(:run_task) { true }
        expect(Rake.application.invoke_task("rake_task_args[first_spec.rb]")).to be_truthy
      end
    end

    default_load_path_opts = '-I\S+'

    context "default" do
      it "renders rspec" do
        expect(spec_command).to match(/^#{ruby} #{default_load_path_opts} #{task.rspec_path}/)
      end
    end

    context "with ruby options" do
      it "renders them before the rspec path" do
        task.ruby_opts = "-w"
        expect(spec_command).to match(/^#{ruby} -w #{default_load_path_opts} #{task.rspec_path}/)
      end
    end

    context "with rspec_opts" do
      it "adds the rspec_opts" do
        task.rspec_opts = "-Ifoo"
        expect(spec_command).to match(/#{task.rspec_path}.*-Ifoo/)
      end
    end

    context "with pattern" do
      it "adds the pattern" do
        task.pattern = "complex_pattern"
        expect(spec_command).to include(" --pattern 'complex_pattern'")
      end
    end

    context 'with custom exit status' do
      it 'returns the correct status on exit', :slow do
        with_isolated_stderr do
          expect($stderr).to receive(:puts) { |cmd| expect(cmd).to match(/-e "exit\(2\);".* failed/) }
          expect(task).to receive(:exit).with(2)
          task.ruby_opts = '-e "exit(2);" ;#'
          task.run_task false
        end
      end
    end

    def loaded_files
      args = Shellwords.split(spec_command)
      args -= [task.class::RUBY, "-S", task.rspec_path]
      config = Configuration.new
      config_options = ConfigurationOptions.new(args)
      config_options.configure(config)
      config.files_to_run
    end

    def specify_consistent_ordering_of_files_to_run(pattern, file_searcher)
      orderings = [
        %w[ a/1.rb a/2.rb a/3.rb ],
        %w[ a/2.rb a/1.rb a/3.rb ],
        %w[ a/3.rb a/2.rb a/1.rb ]
      ].map do |files|
        allow(file_searcher).to receive(:[]).with(anything).and_call_original
        expect(file_searcher).to receive(:[]).with(a_string_including pattern) { files }
        loaded_files
      end

      expect(orderings.uniq.size).to eq(1)
    end

    context "with SPEC env var set" do
      it "sets files to run" do
        with_env_vars 'SPEC' => 'path/to/file' do
          expect(loaded_files).to eq(["path/to/file"])
        end
      end

      it "sets the files to run in a consistent order, regardless of the underlying FileList ordering" do
        with_env_vars 'SPEC' => 'a/*.rb' do
          specify_consistent_ordering_of_files_to_run('a/*.rb', FileList)
        end
      end
    end

    describe "load path manipulation" do
      def self.it_configures_rspec_load_path(description, path_template)
        context "when rspec is installed as #{description}" do
          it "adds the current rspec-core and rspec-support dirs to the load path to ensure the current version is used" do
            $LOAD_PATH.replace([
              path_template % "rspec-core",
              path_template % "rspec-support",
              path_template % "rspec-expectations",
              path_template % "rspec-mocks",
              path_template % "rake"
            ])

            expect(spec_command).to include(" -I#{path_template % "rspec-core"}:#{path_template % "rspec-support"} ")
          end
        end
      end

      it_configures_rspec_load_path "bundler :git dependencies",
        "/Users/myron/code/some-gem/bundle/ruby/2.1.0/bundler/gems/%s-8d2e4e570994/lib"

      it_configures_rspec_load_path "bundler :path dependencies",
        "/Users/myron/code/rspec-dev/repos/%s/lib"

      it_configures_rspec_load_path "a rubygem",
        "/Users/myron/.gem/ruby/1.9.3/gems/%s-3.1.0.beta1/lib"

      it "does not include extra load path entries for other gems that have `rspec-core` in its path" do
        # these are items on my load path due to `bundle install --standalone`,
        # and my initial logic caused all these to be included in the `-I` option.
        $LOAD_PATH.replace([
           "/Users/myron/code/rspec-dev/repos/rspec-core/spec",
           "/Users/myron/code/rspec-dev/repos/rspec-core/bundle/ruby/1.9.1/gems/simplecov-0.8.2/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-core/bundle/ruby/1.9.1/gems/simplecov-html-0.8.0/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-core/bundle/ruby/1.9.1/gems/minitest-5.3.3/lib",
           "/Users/myron/code/rspec-dev/repos/rspec/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-mocks/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-core/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-expectations/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-support/lib",
           "/Users/myron/code/rspec-dev/repos/rspec-core/bundle",
        ])

        expect(spec_command).not_to include("simplecov", "minitest", "rspec-core/spec")
      end
    end

    it "sets the files to run in a consistent order, regardless of the underlying FileList ordering" do
      task.pattern = 'a/*.rb'
      specify_consistent_ordering_of_files_to_run('a/*.rb', Dir)
    end

    context "with a pattern that matches no files" do
      it "runs nothing" do
        task.pattern = 'a/*.no_match'
        expect(loaded_files).to eq([])
      end
    end

    context "without an exclude_pattern" do
      it 'does not pass the --exclude-pattern option' do
        expect(spec_command).not_to include("exclude")
      end
    end

    context "with an exclude_pattern" do
      include_context "isolated directory"

      def make_file(dir, name)
        File.join("spec", dir, name).tap { |f| FileUtils.touch(f) }
      end

      def make_files_in_dir(dir)
        %w[ foo_spec.rb bar_spec.rb ].map do |file_name|
          make_file(dir, file_name)
        end
      end

      before do
        spec_dir = File.join(Dir.getwd, "spec")
        task.exclude_pattern = "spec/acceptance/*_spec.rb"

        FileUtils.mkdir_p(File.join(spec_dir, "acceptance"))
        FileUtils.mkdir_p(File.join(spec_dir, "unit"))

        make_files_in_dir "acceptance"
      end

      it "it does not load matching files" do
        task.pattern = "spec/**/*_spec.rb"
        unit_files = make_files_in_dir "unit"

        expect(loaded_files).to match_array(unit_files)
      end
    end

    context "with paths with quotes or spaces" do
      include_context "isolated directory"

      it "matches files with quotes and spaces" do
        spec_dir = File.join(Dir.getwd, "spec")
        task.pattern = "spec/*spec.rb"
        FileUtils.mkdir_p(spec_dir)

        files = ["first_spec.rb", "second_\"spec.rb", "third_\'spec.rb", "fourth spec.rb"].map do |file_name|
          File.join("spec", file_name).tap { |f| FileUtils.touch(f) }
        end

        expect(loaded_files).to match_array(files)
      end
    end

    context "with paths including symlinked directories" do
      include_context "isolated directory"

      it "finds the files" do
        project_dir = Dir.getwd

        foos_dir = File.join(project_dir, "spec/foos")
        FileUtils.mkdir_p foos_dir
        FileUtils.touch(File.join(foos_dir, "foo_spec.rb"))

        bars_dir = File.join(Dir.tmpdir, "shared/spec/bars")
        FileUtils.mkdir_p bars_dir
        FileUtils.touch(File.join(bars_dir, "bar_spec.rb"))

        FileUtils.ln_s bars_dir, File.join(project_dir, "spec/bars")

        FileUtils.cd(project_dir) do
          expect(loaded_files).to contain_exactly(
            "spec/bars/bar_spec.rb",
            "spec/foos/foo_spec.rb"
          )
        end
      end
    end
  end
end
