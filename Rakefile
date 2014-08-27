require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"
require "yaml"

require "rspec/core/rake_task"

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:cucumber)

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

namespace :spec do
  desc "Run ui examples"
  RSpec::Core::RakeTask.new(:ui) do |t|
    t.ruby_opts = %w[-w]
    t.rspec_opts = %w[--tag ui]
  end
end

require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
task :rubocop do
  sh 'bundle exec rubocop lib'
end

desc "delete generated files"
task :clobber do
  sh 'find . -name "*.rbc" | xargs rm'
  sh 'rm -rf pkg'
  sh 'rm -rf tmp'
  sh 'rm -rf coverage'
  sh 'rm -rf .yardoc'
  sh 'rm -rf doc'
end

desc "generate rdoc"
task :rdoc do
  sh "yardoc"
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |_t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/"
  if `relish versions rspec/rspec-core`.split.map(&:strip).include? args[:version]
    puts "Version #{args[:version]} already exists"
  else
    sh "relish versions:add rspec/rspec-core:#{args[:version]}"
  end
  sh "relish push rspec/rspec-core:#{args[:version]}"
  sh "rm features/Changelog.md"
end

task :default => [:spec, :cucumber, :rubocop]

task :verify_private_key_present do
  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  unless File.exist?(private_key)
    raise "Your private key is not present. This gem should not be built without that."
  end
end

task :build => :verify_private_key_present
