source "https://rubygems.org"

gemspec

def exists_and_version_matches lib, path, const
  version_path  = "lib/#{lib.gsub('-','/')}/version"

  return false unless File.exist?(path)

  require File.join(path, version_path)

  core_major, core_minor, _ = *RSpec::Core::Version::STRING.split('.')
  lib_major,  lib_minor,  _ = *Object.const_get(const)::Version::STRING.split('.')

  core_major == lib_minor && core_minor == lib_minor
end

{ 'rspec' => 'RSpec', 'rspec-expectations' => 'RSpec::Expectations', 'rspec-mocks' => 'RSpec::Mocks' }.each do |lib,const|
  library_path  = File.expand_path("../../#{lib}", __FILE__)
  if exists_and_version_matches(lib, library_path, const)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  end
end

### deps for rdoc.info
platforms :ruby do
  gem 'yard',          '0.8.6.1', :require => false
  gem 'redcarpet',     '2.1.1'
  gem 'github-markup', '0.7.2'
end

### dep for ci/coverage
gem 'coveralls', :require => false

platforms :jruby do
  gem "jruby-openssl"
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
