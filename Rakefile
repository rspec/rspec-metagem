require "bundler"
Bundler.setup

require 'rake'
require 'fileutils'
require 'pathname'

$:.unshift File.expand_path('../lib', __FILE__)

require 'rspec/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec"
    gem.version = RSpec::Version::STRING
    gem.summary = "rspec-#{RSpec::Version::STRING}"
    gem.description = "Meta-gem that depends on the other rspec gems"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/rspec"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.rubyforge_project = "rspec"
    gem.add_dependency "rspec-core", RSpec::Version::STRING
    gem.add_dependency "rspec-expectations", RSpec::Version::STRING
    gem.add_dependency "rspec-mocks", RSpec::Version::STRING
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}

  This is a meta-gem that depends on:
    rspec-core
    rspec-expectations
    rspec-mocks
  
#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-#{RSpec::Version::STRING}.gem"
  end
end

task :clobber do
  rm_rf 'pkg'
end

task :default => [:check_dependencies]
