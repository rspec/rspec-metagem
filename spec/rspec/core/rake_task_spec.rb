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

    context "default" do
      it "renders rspec" do
        expect(spec_command).to match(/^#{ruby} -S rspec/)
      end
    end

    context "with ruby options" do
      it "renders them before -S" do
          task.ruby_opts = "-w"
          expect(spec_command).to match(/^#{ruby} -w -S rspec/)
      end
    end

    context "with rspec_opts" do
      it "adds the rspec_opts" do
        task.rspec_opts = "-Ifoo"
        expect(spec_command).to match(/rspec.*-Ifoo/)
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

    def specify_consistent_ordering_of_files_to_run(pattern, task)
      orderings = [
        %w[ a/1.rb a/2.rb a/3.rb ],
        %w[ a/2.rb a/1.rb a/3.rb ],
        %w[ a/3.rb a/2.rb a/1.rb ]
      ].map do |files|
        expect(FileList).to receive(:[]).with(pattern) { files }
        task.__send__(:files_to_run)
      end

      expect(orderings.uniq.size).to eq(1)
    end

    context "with SPEC env var set" do
      it "sets files to run" do
        with_env_vars 'SPEC' => 'path/to/file' do
          expect(task.__send__(:files_to_run)).to eq(["path/to/file"])
        end
      end

      it "sets the files to run in a consistent order, regardless of the underlying FileList ordering" do
        with_env_vars 'SPEC' => 'a/*.rb' do
          specify_consistent_ordering_of_files_to_run('a/*.rb', task)
        end
      end
    end

    it "sets the files to run in a consistent order, regardless of the underlying FileList ordering" do
      task = RakeTask.new(:consistent_file_order) do |t|
        t.pattern = 'a/*.rb'
      end

      # since the config block is deferred til task invocation, must fake
      # calling the task so the expected pattern is picked up
      expect(task).to receive(:run_task) { true }
      expect(Rake.application.invoke_task(task.name)).to be_truthy

      specify_consistent_ordering_of_files_to_run('a/*.rb', task)
    end

    context "with paths with quotes or spaces" do
      it "escapes the quotes and spaces" do
        task.pattern = File.join(Dir.tmpdir, "*spec.rb")
        ["first_spec.rb", "second_\"spec.rb", "third_\'spec.rb", "fourth spec.rb"].each do |file_name|
          FileUtils.touch(File.join(Dir.tmpdir, file_name))
        end
        expect(task.__send__(:files_to_run).sort).to eq([
          File.join(Dir.tmpdir, "first_spec.rb"),
          File.join(Dir.tmpdir, "fourth\\ spec.rb"),
          File.join(Dir.tmpdir, "second_\\\"spec.rb"),
          File.join(Dir.tmpdir, "third_\\\'spec.rb")
        ])
      end
    end

    context "with paths including symlinked directories" do
      it "finds the files" do
        project_dir = File.join(Dir.tmpdir, "project")
        FileUtils.rm_rf project_dir

        foos_dir = File.join(project_dir, "spec/foos")
        FileUtils.mkdir_p foos_dir
        FileUtils.touch(File.join(foos_dir, "foo_spec.rb"))

        bars_dir = File.join(Dir.tmpdir, "shared/spec/bars")
        FileUtils.mkdir_p bars_dir
        FileUtils.touch(File.join(bars_dir, "bar_spec.rb"))

        FileUtils.ln_s bars_dir, File.join(project_dir, "spec/bars")

        FileUtils.cd(project_dir) do
          expect(RakeTask.new.__send__(:files_to_run).sort).to eq([
            "./spec/bars/bar_spec.rb",
            "./spec/foos/foo_spec.rb"
          ])
        end
      end
    end
  end
end
