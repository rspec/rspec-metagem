# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/version"

Gem::Specification.new do |s|
  s.name        = "rspec"
  s.version     = RSpec::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Steven Baker", "David Chelimsky", "Myron Marston"]
  s.email       = "rspec@googlegroups.com"
  s.homepage    = "http://github.com/rspec"
  s.summary     = "rspec-#{RSpec::Version::STRING}"
  s.description = "BDD for Ruby"

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += ["LICENSE.md"]
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [ "README.md" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    s.signing_key = private_key
    s.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  %w[core expectations mocks].each do |name|
    if RSpec::Version::STRING =~ /[a-zA-Z]+/
      s.add_runtime_dependency "rspec-#{name}", "= #{RSpec::Version::STRING}"
    else
      s.add_runtime_dependency "rspec-#{name}", "~> #{RSpec::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
    end
  end
end
