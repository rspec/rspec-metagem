source "https://rubygems.org"

gemspec

branch = File.read(File.expand_path("../maintenance-branch", __FILE__)).chomp
%w[rspec rspec-core rspec-mocks rspec-support].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => branch
  end
end

gem 'yard', '0.8.7.4', :require => false

### deps for rdoc.info
group :documentation do
  gem 'redcarpet',     '2.1.1',   :platform => :mri
  gem 'github-markup', '0.7.2'
end

gem 'simplecov'

if RUBY_VERSION < '2.0.0' || RUBY_ENGINE == 'java'
  gem 'json', '< 2.0.0' # is a dependency of simplecov
end

platforms :jruby do
  gem "jruby-openssl"
end

platforms :rbx do
  gem 'rubysl'
end

if RUBY_VERSION >= '1.9' && RUBY_VERSION <= '2.1'
  gem 'rubocop', "~> 0.23.0"
  # The latest version (2.2.1) breaks on ruby 1.9.2
  gem 'rainbow', "~> 2.1.0" if RUBY_VERSION == "1.9.2"
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
