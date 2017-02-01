source "https://rubygems.org"

gemspec

branch = File.read(File.expand_path("../maintenance-branch", __FILE__)).chomp
%w[rspec rspec-expectations rspec-mocks rspec-support].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => branch
  end
end

if RUBY_VERSION >= '1.9.3'
  gem 'rake', '>= 10.0.0'
else
  gem 'rake', '< 11.0.0' # rake 11 requires Ruby 1.9.3 or later
end

gem 'yard', '~> 0.8.7', :require => false

### deps for rdoc.info
group :documentation do
  gem 'redcarpet',     '2.1.1', :platform => :mri
  gem 'github-markup', '0.7.2', :platform => :mri
end

if RUBY_VERSION < '2.0.0' || RUBY_ENGINE == 'java'
  gem 'json', '< 2.0.0'
end

if RUBY_VERSION < '2.0.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem 'ffi', '< 1.9.15' # allow ffi to be installed on older rubies on windows
end

platforms :jruby do
  gem "jruby-openssl"
end

gem 'simplecov', '~> 0.8'

if RUBY_VERSION >= '1.9.3' && RUBY_VERSION < '2.4.0' && !(%w[java jruby].include? RUBY_ENGINE)
  gem "rubocop", "~> 0.32.1"
end

gem 'test-unit', '~> 3.0' if RUBY_VERSION.to_f >= 2.2

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
