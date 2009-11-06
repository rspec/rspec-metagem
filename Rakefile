require 'rubygems'
require 'rake'
require 'yaml'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'lib'))

require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'rspec/core/version'
require 'cucumber/rake/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-core"
    gem.summary = "RSpec Core"
    gem.description = 'RSpec Core'
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/core"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.version = Rspec::Core::Version::STRING
    gem.add_development_dependency('rspec-expectations', '>= 2.0.0.a1')
    gem.add_development_dependency('rspec-mocks', '>= 2.0.0.a1')
    gem.add_development_dependency('cucumber', '>= 0.4.2')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rspec::Core::RakeTask.new :spec do |t|
  t.pattern = "spec/**/*_spec.rb"
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

desc "Run all examples using rcov"
Rspec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
  t.rcov = true
  t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
  t.rcov_opts << %[--no-html --aggregate coverage.data]
  t.pattern = "spec/**/*_spec.rb"
end

if RUBY_VERSION == '1.9.1'
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
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-core #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

