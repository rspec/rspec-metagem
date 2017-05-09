source "https://rubygems.org"

gem "rake"
gem "rspec-core", :git => "git@github.com:tonybearpan/rspec-core.git"

%w[rspec-expectations rspec-mocks rspec-support].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end
