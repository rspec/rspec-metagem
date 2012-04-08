require "bundler"
Bundler::GemHelper.install_tasks

require "rake"
require "yaml"

require "rspec/core/rake_task"
require "rspec/core/version"

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:cucumber)

desc "Run non-ui examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

namespace :spec do
  desc "Run ui examples"
  RSpec::Core::RakeTask.new(:ui) do |t|
    t.rspec_opts = %w[--tag ui]
  end
end

if RUBY_VERSION.to_f == 1.8
  namespace :rcov do
    task :cleanup do
      rm_rf 'coverage.data'
    end

    RSpec::Core::RakeTask.new :spec do |t|
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features" --sort coverage --aggregate coverage.data]
    end

    Cucumber::Rake::Task.new :cucumber do |t|
      t.cucumber_opts = %w{--format progress}
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features" --sort coverage --aggregate coverage.data]
    end
  end

  task :rcov => ["rcov:cleanup", "rcov:cucumber", "rcov:spec"]
end

desc "delete generated files"
task :clobber do
  sh %q{find . -name "*.rbc" | xargs rm}
  sh 'rm -rf pkg'
  sh 'rm -rf tmp'
  sh 'rm -rf coverage'
  sh 'rm -rf .yardoc'
  sh 'rm -rf doc'
end

desc "generate rdoc"
task :rdoc do
  sh "yardoc"
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/"
  sh "relish push rspec/rspec-core:#{args[:version]}"
  sh "rm features/Changelog.md"
end

task :default => [:spec, "spec:ui", :cucumber]
