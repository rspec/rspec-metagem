$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'rake'
require 'rspec/expectations/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-expectations"
    gem.version = Rspec::Expectations::Version::STRING
    gem.summary = "rspec-expectations-#{Rspec::Expectations::Version::STRING}"
    gem.description = "rspec expectations (should[_not] and matchers)"
    gem.rubyforge_project = "rspec"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/expectations"
    gem.authors = ["David Chelimsky", "Chad Humphries"]    
    gem.add_development_dependency('cucumber', ">= 0.6.2")
    gem.add_development_dependency('aruba', ">= 0.1.1")
    gem.add_development_dependency('rspec-core', ">= #{Rspec::Expectations::Version::STRING}")
    gem.add_development_dependency('rspec-mocks', ">= #{Rspec::Expectations::Version::STRING}")
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
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-expectations-#{Rspec::Expectations::Version::STRING}.gem"
  end
end

begin
  require 'rspec/core/rake_task'
  Rspec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "Rspec core or one of its dependencies is not installed. Install it with: gem install rspec-core"
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--format progress}
  end
rescue LoadError
  puts "Cucumber or one of its dependencies is not installed. Install it with: gem install cucumber"
end

task :default => [:check_dependencies, :spec, :cucumber]

require 'rake/rdoctask'
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
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end


