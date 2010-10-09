require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"
require "yaml"

require "rake/rdoctask"
require "rspec/core/rake_task"
require "rspec/core/version"
require "cucumber/rake/task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_path = 'bin/rspec'
  t.rspec_opts = %w[--color]
end

desc "Run all examples using rcov"
RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
  t.rcov = true
  t.rspec_opts = %w[--color]
  t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
  t.rcov_opts << %[--no-html --aggregate coverage.data]
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

class Cucumber::Rake::Task::ForkedCucumberRunner
  # When cucumber shells out, we still need it to run in the context of our
  # bundle.
  def run
    sh "bundle exec #{RUBY} " + args.join(" ")
  end
end

if RUBY_VERSION.to_f >= 1.9
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:spec, :cucumber]
else
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,features,spec/ruby_forker,spec/rspec,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
    t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:rcov, :cucumber]
end

desc "Push cukes to relishapp using the relish-client-gem"
task :relish, :path_to_relish, :version do |t, args|
  raise "rake relish[PATH_TO_RELISH, VERSION]" unless args[:version] && args[:path_to_relish]
  sh "ruby -rrubygems -S #{args[:path_to_relish]} --organization rspec --project rspec-core -v #{args[:version]} push"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-core #{RSpec::Core::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

