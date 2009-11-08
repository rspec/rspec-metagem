require 'rubygems'
require 'rake'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'lib'))
require 'rspec/expectations/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-expectations"
    gem.summary = "rspec expectations (should[_not] and matchers)"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.version = Rspec::Expectations::Version::STRING
    gem.homepage = "http://github.com/rspec/expectations"
    gem.authors = ["David Chelimsky", "Chad Humphries"]    
    gem.add_development_dependency('rspec-core', ">= #{Rspec::Expectations::Version::STRING}")
    gem.add_development_dependency('rspec-mocks', ">= #{Rspec::Expectations::Version::STRING}")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'rspec/core/rake_task'
  Rspec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
  end
rescue LoadError
  puts "Rspec core or one of its dependencies is not installed. Install it with: gem install rspec-meta"
end

task :default => [:check_dependencies, :spec]

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-expectations #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

