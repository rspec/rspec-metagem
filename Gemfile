source "http://rubygems.org"

gem "rake"
gem "cucumber"
gem "aruba", ">= 0.2.0"
gem "autotest"
gem "watchr"
gem "rcov"
gem "mocha"
gem "rr"
gem "flexmock"
gem "nokogiri"
gem "syntax"

gem "rspec-core", :path => "."
%w[rspec-expectations rspec-mocks].each do |dependency|
  path = "../#{dependency}"
  gem dependency, :path => (path if File.exist?(path))
end

unless RUBY_PLATFORM == "java"
  case RUBY_VERSION
  when /^1.9.2/
    gem "ruby-debug19"
  when /^1.8/
    gem "ruby-debug"
  end
end
