require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'
require 'rspec/expectations/version'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/"
  if `relish versions rspec/rspec-expectations`.split.map(&:strip).include? args[:version]
    puts "Version #{args[:version]} already exists"
  else
    sh "relish versions:add rspec/rspec-expectations:#{args[:version]}"
  end
  sh "relish push rspec/rspec-expectations:#{args[:version]}"
  sh "rm features/Changelog.md"
end

namespace :clobber do
  desc "delete generated .rbc files"
  task :rbc do
    sh %q{find . -name "*.rbc" | xargs rm}
  end
end

desc "delete generated files"
task :clobber => ["clobber:rbc"] do
  rm_rf 'doc'
  rm_rf '.yardoc'
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

task :default => [:spec, :cucumber]

task :verify_private_key_present do
  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  unless File.exist?(private_key)
    raise "Your private key is not present. This gem should not be built without that."
  end
end

task :build => :verify_private_key_present

