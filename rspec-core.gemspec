# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspec-core}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky", "Chad Humphries"]
  s.date = %q{2009-06-29}
  s.default_executable = %q{rspec}
  s.email = %q{dchelimsky@gmail.com;chad.humphries@gmail.com}
  s.executables = ["rspec"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "License.txt",
    "README.markdown",
    "Rakefile",
    "TODO.markdown",
    "bin/rspec",
    "lib/rspec/core.rb",
    "lib/rspec/core/behaviour.rb",
    "lib/rspec/core/configuration.rb",
    "lib/rspec/core/deprecation.rb",
    "lib/rspec/core/example.rb",
    "lib/rspec/core/formatters.rb",
    "lib/rspec/core/formatters/base_formatter.rb",
    "lib/rspec/core/formatters/base_text_formatter.rb",
    "lib/rspec/core/formatters/documentation_formatter.rb",
    "lib/rspec/core/formatters/progress_formatter.rb",
    "lib/rspec/core/kernel_extensions.rb",
    "lib/rspec/core/mocking/with_absolutely_nothing.rb",
    "lib/rspec/core/mocking/with_mocha.rb",
    "lib/rspec/core/mocking/with_rr.rb",
    "lib/rspec/core/mocking/with_rspec.rb",
    "lib/rspec/core/rake_task.rb",
    "lib/rspec/core/runner.rb",
    "lib/rspec/core/world.rb",
    "spec/lib/rspec/core/behaviour_spec.rb",
    "spec/lib/rspec/core/configuration_spec.rb",
    "spec/lib/rspec/core/example_spec.rb",
    "spec/lib/rspec/core/formatters/base_formatter_spec.rb",
    "spec/lib/rspec/core/formatters/documentation_formatter_spec.rb",
    "spec/lib/rspec/core/formatters/progress_formatter_spec.rb",
    "spec/lib/rspec/core/kernel_extensions_spec.rb",
    "spec/lib/rspec/core/mocha_spec.rb",
    "spec/lib/rspec/core/runner_spec.rb",
    "spec/lib/rspec/core/world_spec.rb",
    "spec/lib/rspec/core_spec.rb",
    "spec/resources/example_classes.rb",
    "spec/ruby_forker.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/rspec/core}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{RSpec Core}
  s.test_files = [
    "spec/lib/rspec/core/behaviour_spec.rb",
    "spec/lib/rspec/core/configuration_spec.rb",
    "spec/lib/rspec/core/example_spec.rb",
    "spec/lib/rspec/core/formatters/base_formatter_spec.rb",
    "spec/lib/rspec/core/formatters/documentation_formatter_spec.rb",
    "spec/lib/rspec/core/formatters/progress_formatter_spec.rb",
    "spec/lib/rspec/core/kernel_extensions_spec.rb",
    "spec/lib/rspec/core/mocha_spec.rb",
    "spec/lib/rspec/core/runner_spec.rb",
    "spec/lib/rspec/core/world_spec.rb",
    "spec/lib/rspec/core_spec.rb",
    "spec/resources/example_classes.rb",
    "spec/ruby_forker.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
