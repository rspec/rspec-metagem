# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/expectations/version"

Gem::Specification.new do |s|
  s.name        = "rspec-expectations"
  s.version     = RSpec::Expectations::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Steven Baker", "David Chelimsky"]
  s.email       = "rspec-users@rubyforge.org"
  s.homepage    = "http://github.com/rspec/rspec-expectations"
  s.summary     = "rspec-expectations-#{RSpec::Expectations::Version::STRING}"
  s.description = "rspec expectations (should[_not] and matchers)"

  s.rubyforge_project  = "rspec"

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += ["License.txt"]
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files = [ "README.md", "License.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency     'diff-lcs', '~> 1.1.3'

  s.add_development_dependency 'rake',     '~> 0.9.2'
  s.add_development_dependency 'cucumber', '~> 1.1.0'
  s.add_development_dependency 'aruba',    '~> 0.4.5'
  s.add_development_dependency 'nokogiri', '1.5.0'
end
