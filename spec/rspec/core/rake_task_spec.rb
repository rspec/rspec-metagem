require "spec_helper"
require "rspec/core/rake_task"

module RSpec::Core
  describe RakeTask do
    let(:task) { RakeTask.new }

    def ruby
      FileUtils::RUBY
    end

    before do
      File.stub(:exist?) { false }
    end

    def with_bundler
      task.skip_bundler = false
      File.stub(:exist?) { true }
      yield
    end

    def with_rcov
      task.rcov = true
      yield
    end

    def spec_command
      task.__send__(:spec_command)
    end

    context "default" do
      it "renders rspec" do
        spec_command.should =~ /^#{ruby} -S rspec/
      end
    end

    context "with bundler" do
      context "with Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) { true }
          task.skip_bundler = false
          spec_command.should match(/bundle exec/)
        end
      end

      context "with non-standard Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) {|f| f =~ /AltGemfile/}
          task.gemfile = 'AltGemfile'
          task.skip_bundler = false
          spec_command.should match(/bundle exec/)
        end
      end

      context "without Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) { false }
          task.skip_bundler = false
          spec_command.should_not match(/bundle exec/)
        end
      end
    end

    context "with rcov" do
      it "renders rcov" do
        with_rcov do
          spec_command.should =~ /^#{ruby} -S rcov/
        end
      end
    end

    context "with bundler and rcov" do
      it "renders bundle exec rcov" do
        with_bundler do
          with_rcov do
            spec_command.should =~ /^bundle exec #{ruby} -S rcov/
          end
        end
      end
    end

    context "with ruby options" do
      it "renders them before -S" do
        task.ruby_opts = "-w"
        spec_command.should =~ /^#{ruby} -w -S rspec/
      end
    end

    context "with rcov_opts" do
      context "with rcov=false (default)" do
        it "does not add the rcov options to the command" do
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should_not =~ /--exclude "mocks"/
        end
      end

      context "with rcov=true" do
        it "renders them after rcov" do
          task.rcov = true
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should =~ /rcov.*--exclude "mocks"/
        end

        it "ensures that -Ispec:lib is in the resulting command" do
          task.rcov = true
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should =~ /rcov.*-Ispec:lib/
        end
      end
    end

    context "with rspec_opts" do
      context "with rcov=true" do
        it "adds the rspec_opts after the rcov_opts and files" do
          task.stub(:files_to_run) { "this.rb that.rb" }
          task.rcov = true
          task.rspec_opts = "-Ifoo"
          spec_command.should =~ /this.rb that.rb -- -Ifoo/
        end
      end
      context "with rcov=false (default)" do
        it "adds the rspec_opts" do
          task.rspec_opts = "-Ifoo"
          spec_command.should =~ /rspec -Ifoo/
        end
      end
    end

    context "with SPEC=path/to/file" do
      before do
        @orig_spec = ENV["SPEC"]
        ENV["SPEC"] = "path/to/file"
      end

      after do
        ENV["SPEC"] = @orig_spec
      end

      it "sets files to run" do
        task.__send__(:files_to_run).should eq(["path/to/file"])
      end
    end

    context "with paths with quotes" do
      before do
        @tmp_dir = File.expand_path('./tmp/rake_task_example/')
        FileUtils.mkdir_p @tmp_dir
        @task = RakeTask.new do |t|
          t.pattern = File.join(@tmp_dir, "*spec.rb")
        end
        ["first_spec.rb", "second_\"spec.rb", "third_\'spec.rb"].each do |file_name|
          FileUtils.touch(File.join(@tmp_dir, file_name))
        end
      end

      it "escapes the quotes" do
        @task.__send__(:files_to_run).sort.should eq([
          File.join(@tmp_dir, "first_spec.rb"),
          File.join(@tmp_dir, "second_\\\"spec.rb"),
          File.join(@tmp_dir, "third_\\\'spec.rb") 
        ])
      end
    end

    context "with paths including symlinked directories" do
      it "finds the files" do
        task = RakeTask.new
        base_dir = File.expand_path('./tmp/base')
        FileUtils.rm_rf base_dir

        models_dir = File.expand_path('./tmp/base/spec/models')
        FileUtils.rm_rf models_dir
        FileUtils.mkdir_p models_dir
        FileUtils.touch(File.join(models_dir, "any_model_spec.rb"))

        target_parent_dir = File.expand_path('./tmp/target_parent_dir')
        FileUtils.rm_rf target_parent_dir
        FileUtils.mkdir_p target_parent_dir

        target_dir = File.expand_path('./tmp/target_parent_dir/controllers')
        FileUtils.rm_rf target_dir
        FileUtils.mkdir_p target_dir
        FileUtils.touch(File.join(target_dir, "any_controller_spec.rb"))

        controllers_dir = File.expand_path('./tmp/base/spec/controllers')
        FileUtils.ln_s target_dir, controllers_dir

        File.exists?(controllers_dir).should be_true

        FileUtils.cd(base_dir) do
          task.__send__(:files_to_run).sort.should eq(["./spec/controllers/any_controller_spec.rb", "./spec/models/any_model_spec.rb"])
        end
      end
    end
  end
end
