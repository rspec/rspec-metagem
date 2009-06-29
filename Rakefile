require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-meta"
    gem.summary = "pulls in the other rspec gems"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/meta"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.add_dependency "rspec-core", "0.0.0"
    gem.add_dependency "rspec-expectations", "0.0.0"
    gem.add_dependency "rspec-mocks", "0.0.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
task :spec do
  system <<-COMMANDS
    cd ../core &&
    rake spec &&
    cd ../mocks &&
    rake spec &&
    cd ../expectations &&
    rake spec
  COMMANDS
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-meta #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :git do
  "git status on all the repos"
  task :status do
    ["../core","../expectations", "../mocks"].each do |repo|
      puts
      puts "*" * 50
      puts "git status of #{repo}:"
      puts `cd #{repo} && git status`
      puts "*" * 50
    end
  end
end
