require "spec_helper"
require "rspec/core/rake_task"

module RSpec::Core
  describe RakeTask do
    let(:task) { RakeTask.new }

    def with_bundler
      File.stub(:exist?) { true }
      yield
    end

    def without_bundler
      File.stub(:exist?) { false }
      yield
    end

    def with_rcov
      task.rcov = true
      yield
    end

    def without_rcov
      yield
    end

    def spec_command
      task.__send__(:spec_command)
    end

    context "without bundler" do
      context "without rcov" do
        it "renders rspec" do
          without_bundler do
            without_rcov do
              spec_command.should =~ /^rspec/
            end
          end
        end
      end

      context "with rcov" do
        it "renders rcov" do
          without_bundler do
            with_rcov do
              spec_command.should =~ /^rcov/
            end
          end
        end
      end
    end

    context "with bundler" do
      context "without rcov" do
        it "renders bundle exec rspec" do
          with_bundler do
            without_rcov do
              spec_command.should =~ /^bundle exec rspec/
            end
          end
        end
      end

      context "with rcov" do
        it "renders bundle exec rcov" do
          with_bundler do
            with_rcov do
              spec_command.should =~ /^bundle exec rcov/
            end
          end
        end
      end
    end

  end
end
