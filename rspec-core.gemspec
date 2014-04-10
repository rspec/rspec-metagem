# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/core/version"

Gem::Specification.new do |s|
  s.name        = "rspec-core"
  s.version     = RSpec::Core::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Steven Baker", "David Chelimsky", "Chad Humphries", "Myron Marston"]
  s.email       = "rspec@googlegroups.com"
  s.homepage    = "http://github.com/rspec/rspec-core"
  s.summary     = "rspec-core-#{RSpec::Core::Version::STRING}"
  s.description = "BDD for Ruby. RSpec runner and example groups."

  s.rubyforge_project  = "rspec"

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += %w[README.md License.txt Changelog.md .yardopts .document]
  s.test_files       = []
  s.bindir           = 'exe'
  s.executables      = `git ls-files -- exe/*`.split("\n").map{ |f| File.basename(f) }
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.required_ruby_version = '>= 1.8.7'

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    s.signing_key = private_key
    s.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  if RSpec::Core::Version::STRING =~ /[a-zA-Z]+/
    # rspec-support is locked to our version when running pre,rc etc
    s.add_runtime_dependency "rspec-support", "= #{RSpec::Core::Version::STRING}"
  else
    # rspec-support must otherwise match our major/minor version
    s.add_runtime_dependency "rspec-support", "~> #{RSpec::Core::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
  end

  s.add_development_dependency "rake",     "~> 10.0.0"
  s.add_development_dependency "cucumber", "~> 1.3"
  s.add_development_dependency "minitest", "~> 5.3"
  s.add_development_dependency "aruba",    "~> 0.5"

  s.add_development_dependency "nokogiri", "1.5.2"
  s.add_development_dependency "coderay",  "~> 1.0.9"

  s.add_development_dependency "mocha",    "~> 0.13.0"
  s.add_development_dependency "rr",       "~> 1.0.4"
  s.add_development_dependency "flexmock", "~> 0.9.0"

  # For legacy custom formatter regression tests
  s.add_development_dependency "fuubar",                 "1.3.2"
  s.add_development_dependency "nyan-cat-formatter",     "0.5.2"
  s.add_development_dependency "rspec-instafail",        "0.2.4"
  s.add_development_dependency "rspec_spinner",          "2.0.0"
  s.add_development_dependency "rspec-extra-formatters", "1.0.0"
end
