require 'rubygems'
require 'rake'
require 'fileutils'
require 'pathname'

begin
  # require 'jeweler'
  # Jeweler::Tasks.new do |gem|
    # gem.name = "rspec-meta"
    # gem.summary = "pulls in the other rspec gems"
    # gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    # gem.homepage = "http://github.com/rspec/meta"
    # gem.authors = ["David Chelimsky", "Chad Humphries"]
    # gem.add_dependency "rspec-core", ">= 2.0.0.a1"
    # gem.add_dependency "rspec-expectations", ">= 2.0.0.a1"
    # gem.add_dependency "rspec-mocks", ">= 2.0.0.a1"
    # gem.add_development_dependency 'git'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  # end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

def run_command(command)
  base_rspec2_path = Pathname.new(Dir.pwd.split('meta').first)
  ['meta', 'core', 'expectations', 'mocks'].each do |dir|
    path = base_rspec2_path.join(dir)
    puts "====================================="
    puts "Running [#{command}] in #{path}"
    puts "====================================="
    FileUtils.cd(path) do
      system command
    end
    puts 
  end
end

task :clobber do
  rm_rf 'pkg'
end

task :spec do
  run_command 'rake'
end

task :default => :spec

namespace :git do

  { :status => nil,
    :pull => '--rebase',
    :push => nil,
    :reset => '--hard',
    :diff => nil
  }.each do |command, options|
    desc "git #{command} on all the repos"
    task command do
      run_command "git #{command} #{options}".strip
    end
  end

  task :st => :status
end
