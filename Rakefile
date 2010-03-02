require 'rubygems'
gem 'jeweler', ">= 1.4.0"
require 'rake'
require 'fileutils'
require 'pathname'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'lib'))

require 'rspec/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec"
    gem.version = Rspec::Version::STRING
    gem.summary = "rspec-#{Rspec::Version::STRING}"
    gem.description = "Meta-gem that depends on the other rspec gems"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/meta"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.rubyforge_project = "rspec"
    gem.add_dependency "rspec-core", Rspec::Version::STRING
    gem.add_dependency "rspec-expectations", Rspec::Version::STRING
    gem.add_dependency "rspec-mocks", Rspec::Version::STRING
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}

  This is beta software. If you are looking
  for a supported production release, please
  "gem install rspec" (without --pre).
  
#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :clobber do
  rm_rf 'pkg'
end

task :default => [:check_dependencies]
