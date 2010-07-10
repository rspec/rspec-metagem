require 'bundler'
Bundler.setup

$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'rake'
require 'rake/rdoctask'
require 'rspec/expectations/version'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-expectations"
    gem.version = RSpec::Expectations::Version::STRING
    gem.summary = "rspec-expectations-#{RSpec::Expectations::Version::STRING}"
    gem.description = "rspec expectations (should[_not] and matchers)"
    gem.rubyforge_project = "rspec"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/expectations"
    gem.authors = ["David Chelimsky", "Chad Humphries"]    
    gem.add_dependency('diff-lcs', ">= 1.1.2")
    gem.add_development_dependency('cucumber', ">= 0.6.2")
    gem.add_development_dependency('aruba', ">= 0.1.1")
    gem.add_development_dependency('rspec-core', ">= #{RSpec::Expectations::Version::STRING}")
    gem.add_development_dependency('rspec-mocks', ">= #{RSpec::Expectations::Version::STRING}")
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}

#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-expectations-#{RSpec::Expectations::Version::STRING}.gem"
  end
end

RSpec::Core::RakeTask.new(:spec)

class Cucumber::Rake::Task::ForkedCucumberRunner
  # When cucumber shells out, we still need it to run in the context of our
  # bundle.
  def run
    sh "bundle exec #{RUBY} " + args.join(" ")
  end
end

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

task :default => [:check_dependencies, :spec, :cucumber]

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-expectations #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :clobber do
  rm_rf 'doc'
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end


