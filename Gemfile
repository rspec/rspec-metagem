source "http://rubygems.org"

%w[rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "rake"
gem "cucumber", "0.9.4"
gem "aruba", "0.2.2"
gem "autotest"
gem "rcov"
gem "mocha"
gem "rr"
gem "flexmock"
gem "nokogiri"
gem "syntax"
gem "relish", "~> 0.0.3"
gem "guard-rspec"
gem "growl"

gem "ruby-debug", :platforms => :ruby_18
gem "ruby-debug19", :platforms => :ruby_19

platforms :ruby_18, :ruby_19 do
  gem "rb-fsevent"
  gem "ruby-prof"
end
