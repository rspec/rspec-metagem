source "http://rubygems.org"

gem "bundler"
gem "rake"
gem "jeweler"
gem "cucumber"
gem "aruba", :git => "git://github.com/dchelimsky/aruba.git", :branch => "add-gemspec"
gem "autotest"
gem "watchr"
gem "rcov"
gem "mocha"
gem "rr"
gem "flexmock"
gem "rspec-core", :path => "."
gem "rspec-expectations", :path => "../rspec-expectations"
gem "rspec-mocks", :path => "../rspec-mocks"
if RUBY_VERSION.to_s =~ /1.9.1/
  gem "ruby-debug19"
elsif RUBY_VERSION.to_s =~ /1.9.2/
else
  gem "ruby-debug"
end
