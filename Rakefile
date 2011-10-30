require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'
require 'rspec/expectations/version'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.ruby_opts = %w[-w]
end

if RUBY_VERSION.to_f == 1.8
  namespace :rcov do
    desc "Run all examples using rcov"
    RSpec::Core::RakeTask.new :spec => :cleanup_rcov_files do |t|
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--text-report --sort coverage --no-html --aggregate coverage.data]
    end
    desc "Run cucumber features using rcov"
    Cucumber::Rake::Task.new :cucumber => :cleanup_rcov_files do |t|
      t.cucumber_opts = %w{--format progress}
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    end
  end
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/"
  sh "relish push rspec/rspec-expectations:#{args[:version]}"
  sh "rm features/Changelog.md"
end

namespace :clobber do
  desc "delete generated .rbc files"
  task :rbc do
    sh %q{find . -name "*.rbc" | xargs rm}
  end
end

desc "delete generated files"
task :clobber => ["clobber:rbc"] do
  rm_rf 'doc'
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

task :default => [:spec, :cucumber]
