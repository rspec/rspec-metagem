require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'fileutils'
require 'pathname'

task :clobber do
  rm_rf 'pkg'
end

task :default do
  puts "Nothing to do for the default task"
end

task :verify_private_key_present do
  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  unless File.exist?(private_key)
    raise "Your private key is not present. This gem should not be built without that."
  end
end

task :build => :verify_private_key_present

