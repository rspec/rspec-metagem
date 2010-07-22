require "bundler"
Bundler.setup

gem "jeweler", ">= 1.4.0"
require "rake"
require "yaml"

$:.unshift File.expand_path("../lib", __FILE__)

require "rake/rdoctask"
require "rspec/core/rake_task"
require "rspec/core/version"
require "cucumber/rake/task"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-core"
    gem.version = RSpec::Core::Version::STRING
    gem.summary = "rspec-core-#{RSpec::Core::Version::STRING}"
    gem.description = "RSpec runner and example groups"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/rspec-core"
    gem.authors = ["Chad Humphries", "David Chelimsky"]
    gem.rubyforge_project = "rspec"
    gem.add_development_dependency "rspec-expectations", ">= #{RSpec::Core::Version::STRING}"
    gem.add_development_dependency "rspec-mocks", ">= #{RSpec::Core::Version::STRING}"
    gem.add_development_dependency "cucumber", ">= 0.5.3"
    gem.add_development_dependency "autotest", ">= 4.2.9"
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}

  Please be sure to look at Upgrade.markdown to see what might have changed
  since the last release.

#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-core-#{RSpec::Core::Version::STRING}.gem"
  end
end

RSpec::Core::RakeTask.new(:spec)

desc "Run all examples using rcov"
RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
  t.rcov = true
  t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
  t.rcov_opts << %[--no-html --aggregate coverage.data]
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

class Cucumber::Rake::Task::ForkedCucumberRunner
  # When cucumber shells out, we still need it to run in the context of our
  # bundle.
  def run
    sh "bundle exec #{RUBY} " + args.join(" ")
  end
end

if RUBY_VERSION.to_f >= 1.9
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:check_dependencies, :spec, :cucumber]
else
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "mocks,expectations,gems/*,features,spec/ruby_forker,spec/rspec,spec/resources,spec/lib,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
    t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    t.cucumber_opts = %w{--format progress}
  end

  task :default => [:check_dependencies, :rcov, :cucumber]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-core #{RSpec::Core::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

