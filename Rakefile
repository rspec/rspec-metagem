gem "jeweler", ">= 1.4.0"
require 'rake'
require 'yaml'

$:.unshift File.expand_path('../lib', __FILE__)

require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'rspec/core/version'
require 'cucumber/rake/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-core"
    gem.version = Rspec::Core::Version::STRING
    gem.summary = Rspec::Core::Version::SUMMARY
    gem.description = 'Rspec runner and example group classes'
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/core"
    gem.authors = ["Chad Humphries", "David Chelimsky"]
    gem.rubyforge_project = "rspec"
    gem.add_development_dependency "rspec-expectations", ">= #{Rspec::Core::Version::STRING}"
    gem.add_development_dependency "rspec-mocks", ">= #{Rspec::Core::Version::STRING}"
    gem.add_development_dependency('cucumber', '>= 0.5.3')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  Rspec::Core::RakeTask.new :spec

  desc "Run all examples using rcov"
  Rspec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
    t.rcov_opts << %[--no-html --aggregate coverage.data]
  end
rescue LoadError
  puts "Rspec core or one of its dependencies is not installed. Install it with: gem install rspec-meta"
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

if RUBY_VERSION.to_f >= 1.9
  Cucumber::Rake::Task.new :features do |t|
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:check_dependencies, :spec, :features]
else
  Cucumber::Rake::Task.new :features do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,features,spec/ruby_forker,spec/rspec,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
    t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:check_dependencies, :rcov, :features]
end


Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-core #{Rspec::Core::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

