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

gem 'coderay' # for syntax highlighting
gem 'yard', '~> 0.9.12', :require => false

### deps for rdoc.info
group :documentation do
  gem 'redcarpet',     '2.1.1',   :platform => :mri
  gem 'github-markup', '0.7.2'
end

gem 'simplecov'

if RUBY_VERSION < '2.0.0' || RUBY_ENGINE == 'java'
  gem 'json', '< 2.0.0' # is a dependency of simplecov
end

# allow gems to be installed on older rubies and/or windows
if RUBY_VERSION < '2.2.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem 'ffi', '< 1.10'
elsif RUBY_VERSION < '1.9'
  gem 'ffi', '< 1.9.19' # ffi dropped Ruby 1.8 support in 1.9.19
else
  gem 'ffi', '> 1.9.24' # prevent Github security vulnerability warning
end

if RUBY_VERSION < '2.2.0' && !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
  gem "childprocess", "< 1.0.0"
end

platforms :jruby do
  if RUBY_VERSION < '1.9.0'
    # Pin jruby-openssl on older J Ruby
    gem "jruby-openssl", "< 0.10.0"
    # Pin childprocess on older J Ruby
    gem "childprocess", "< 1.0.0"
  else
    gem "jruby-openssl"
  end
end

platforms :rbx do
  gem 'rubysl'
end

if RUBY_VERSION >= '2.4' && RUBY_ENGINE == 'ruby'
  gem 'rubocop', "~> 0.52.1"
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
