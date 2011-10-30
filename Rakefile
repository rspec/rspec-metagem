require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

task :build => :raise_if_psych_is_defined

task :raise_if_psych_is_defined do
  if defined?(Psych)
    raise <<-MSG
===============================================================================
Gems compiled in Ruby environments with Psych loaded are incompatible with Ruby
environments that don't have Psych loaded. Try building this gem in Ruby 1.8.7
instead.
===============================================================================
MSG
  end
end

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
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--no-html --aggregate coverage.data]
    end

    Cucumber::Rake::Task.new :cucumber do |t|
      t.cucumber_opts = %w{--format progress}
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    end
  end

  task :rcov => ["rcov:cleanup", "rcov:spec", "rcov:cucumber"]
end

desc "delete generated files"
task :clobber do
  sh %q{find . -name "*.rbc" | xargs rm}
  sh 'rm -rf pkg'
  sh 'rm -rf tmp'
  sh 'rm -rf coverage'
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/"
  sh "relish push rspec/rspec-core:#{args[:version]}"
  sh "rm features/Changelog.md"
end

task :default => [:spec, "spec:ui", :cucumber]
