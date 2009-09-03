require 'rubygems'
require 'rake'
require 'yaml'

$:.unshift 'lib'

require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

begin
  # require 'jeweler'
  # Jeweler::Tasks.new do |gem|
    # gem.name = "rspec-core"
    # gem.summary = "RSpec Core"
    # gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    # gem.homepage = "http://github.com/rspec/core"
    # gem.authors = ["David Chelimsky", "Chad Humphries"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  # end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rspec::Core::RakeTask.new :spec do |t|
  t.ruby_opts = %[-Ilib -Ispec]
  t.pattern = "spec/**/*_spec.rb"
end

Cucumber::Rake::Task.new :cucumber

desc "Run all examples using rcov"
Rspec::Core::RakeTask.new :rcov do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rcov = true
  t.ruby_opts = %[-Ilib -Ispec]
  t.rcov_opts = %[--exclude "mocks,expectations,gems/*,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
end

task :default => [:spec, :cucumber]

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

