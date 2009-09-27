require 'rubygems'
require 'rake'
require 'fileutils'
require 'pathname'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-meta"
    gem.summary = "pulls in the other rspec gems"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/meta"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.add_dependency "rspec-core", ">= 2.0.0.a1"
    gem.add_dependency "rspec-expectations", ">= 2.0.0.a1"
    gem.add_dependency "rspec-mocks", ">= 2.0.0.a1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

def arbitrary_command(command)
  # Jeweler sets some ENV keys for GIT that cause our normal flow to explode
  ENV.keys.grep(/GIT/).each { |k| ENV.delete(k) }
  base_rspec2_path = Pathname.new(Dir.pwd.split('meta').first)
  ['meta', 'core', 'expectations', 'mocks'].each do |dir|
    path = base_rspec2_path.join(dir)
    puts "====================================="
    puts "Running [#{command}] in #{path}"
    puts "====================================="
    if command.include?('git')
      system command.sub(/^git/, "git --git-dir=#{path}/.git --work-tree=#{path}")
    else
      system command
    end
    puts 
  end
end

task :clobber do
  rm_rf 'pkg'
end

task :spec do
  arbitrary_command('rake')
end

task :default => :spec

namespace :git do
  [:status, :pull, :push, :reset, :diff].each do |key|
    command = key == :reset ? "reset --hard" : key.to_s
    desc "git #{command} on all the repos"
    task key do
      arbitrary_command("git #{command}")
    end
  end

  task :st => :status
end
