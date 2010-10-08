require "spec_helper"
require "rspec/core/rake_task"

module RSpec::Core
  describe RakeTask do
    let(:task) { RakeTask.new }

    before do
      File.stub(:exist?) { false }
    end

    def with_bundler
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
        spec_command.should =~ /^-S rspec/
      end
    end

    context "with bundler" do
      it "renders bundle exec rspec" do
        with_bundler do
          spec_command.should =~ /^-S bundle exec rspec/
        end
      end
    end

    context "with rcov" do
      it "renders rcov" do
        with_rcov do
          spec_command.should =~ /^-S rcov/
        end
      end
    end

    context "with bundler and rcov" do
      it "renders bundle exec rcov" do
        with_bundler do
          with_rcov do
            spec_command.should =~ /^-S bundle exec rcov/
          end
        end
      end
    end

    context "with warnings on" do
      before { RSpec.stub(:deprecate) }

      it "renders -w before the -S" do
        task.warning = true
        spec_command.should =~ /^-w -S rspec/
      end

      it "warns about deprecation" do
        RSpec.should_receive(:deprecate)
        task.warning = true
      end
    end

    context "with ruby options" do
      it "renders them before -S" do
        task.ruby_opts = "-w"
        spec_command.should =~ /^-w -S rspec/
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

        it "ensures that -Ispec is in the resulting command" do
          task.rcov = true
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should =~ /rcov.*-Ispec/
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

    context "with spec_opts" do
      before { RSpec.stub(:deprecate) }

      it "warns about deprecation" do
        RSpec.should_receive(:deprecate)
        task.spec_opts = "-Ifoo"
      end

      it "adds options as rspec_opts" do
        task.spec_opts = "-Ifoo"
        spec_command.should =~ /rspec -Ifoo/
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
  end
end
