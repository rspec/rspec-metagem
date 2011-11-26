source "http://rubygems.org"

### rspec libs
%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  end
end

### dev dependencies
gem "rake", "~> 0.9.2"
gem "cucumber", "1.0.1"
gem "aruba", "0.4.2"
gem "ZenTest", "4.6.2"
gem "nokogiri", "1.5.0"
gem "fakefs", "0.4.0", :require => "fakefs/safe"

platforms :jruby do
  gem "jruby-openssl"
end

### rspec-core only
gem "mocha", "~> 0.9.10"
gem "rr", "~> 1.0.2"
gem "flexmock", "0.8.8"

### optional runtime deps
gem "syntax", "1.0.0"

group :development do
  platforms :mri_18, :jruby do
    gem "rcov", "0.9.10"
  end
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
