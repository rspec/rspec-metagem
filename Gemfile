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

if RUBY_VERSION >= '2.0.0'
  gem 'rake', '>= 10.0.0'
elsif RUBY_VERSION >= '1.9.3'
  gem 'rake', '< 12.0.0' # rake 12 requires Ruby 2.0.0 or later
else
  gem 'rake', '< 11.0.0' # rake 11 requires Ruby 1.9.3 or later
end

gem 'yard', '~> 0.9.12', :require => false

### deps for rdoc.info
group :documentation do
  gem 'redcarpet',     '2.1.1', :platform => :mri
  gem 'github-markup', '0.7.2', :platform => :mri
end

if RUBY_VERSION < '2.0.0' || RUBY_ENGINE == 'java'
  gem 'json', '< 2.0.0'
end

if RUBY_VERSION < '2.2.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem 'ffi', '< 1.10'
elsif RUBY_VERSION < '2.0.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem 'ffi', '< 1.9.15' # allow ffi to be installed on older rubies on windows
elsif RUBY_VERSION < '1.9'
  gem 'ffi', '< 1.9.19' # ffi dropped Ruby 1.8 support in 1.9.19
else
  gem 'ffi', '~> 1.9.25'
end

if RUBY_VERSION < '2.2.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem "childprocess", "< 1.0.0"
end

platforms :jruby do
  if RUBY_VERSION < '1.9.0'
    # Pin jruby-openssl on older J Ruby
    gem "jruby-openssl", "< 0.10.0"
    # Pin child-process on older J Ruby
    gem "childprocess", "< 1.0.0"
  else
    gem "jruby-openssl"
  end
end

gem 'simplecov', '~> 0.8'

# No need to run rubocop on earlier versions
if RUBY_VERSION >= '2.4' && RUBY_ENGINE == 'ruby'
  gem "rubocop", "~> 0.52.1"
end

gem 'test-unit', '~> 3.0' if RUBY_VERSION.to_f >= 2.2

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
