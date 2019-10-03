$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/expectations/version"

Gem::Specification.new do |s|
  s.name        = "rspec-expectations"
  s.version     = RSpec::Expectations::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Steven Baker", "David Chelimsky", "Myron Marston"]
  s.email       = "rspec@googlegroups.com"
  s.homepage    = "https://github.com/rspec/rspec-expectations"
  s.summary     = "rspec-expectations-#{RSpec::Expectations::Version::STRING}"
  s.description = "rspec-expectations provides a simple, readable API to express expected outcomes of a code example."

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/rspec/rspec-expectations/issues',
    'changelog_uri'     => "https://github.com/rspec/rspec-expectations/blob/v#{s.version}/Changelog.md",
    'documentation_uri' => 'https://rspec.info/documentation/',
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/rspec',
    'source_code_uri'   => 'https://github.com/rspec/rspec-expectations',
  }

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += %w[README.md LICENSE.md Changelog.md .yardopts .document]
  s.test_files       = []
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.required_ruby_version = '>= 1.8.7' # rubocop:disable Gemspec/RequiredRubyVersion

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    s.signing_key = private_key
    s.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  if RSpec::Expectations::Version::STRING =~ /[a-zA-Z]+/
    # pin to exact version for rc's and betas
    s.add_runtime_dependency "rspec-support", "= #{RSpec::Expectations::Version::STRING}"
  else
    # pin to major/minor ignoring patch
    s.add_runtime_dependency "rspec-support", "~> #{RSpec::Expectations::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
  end

  s.add_runtime_dependency "diff-lcs", ">= 1.2.0", "< 2.0"

  s.add_development_dependency "aruba",    "~> 0.14.10"
  s.add_development_dependency 'cucumber', '~> 1.3'
  s.add_development_dependency 'minitest', '~> 5.2'
  s.add_development_dependency 'rake',     '~> 10.0.0'
end
