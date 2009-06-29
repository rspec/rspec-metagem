# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspec-expectations}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky", "Chad Humphries"]
  s.date = %q{2009-06-29}
  s.email = %q{dchelimsky@gmail.com;chad.humphries@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "License.txt",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "lib/spec/expectations.rb",
    "lib/spec/expectations/differs/default.rb",
    "lib/spec/expectations/differs/load-diff-lcs.rb",
    "lib/spec/expectations/errors.rb",
    "lib/spec/expectations/extensions.rb",
    "lib/spec/expectations/extensions/kernel.rb",
    "lib/spec/expectations/fail_with.rb",
    "lib/spec/expectations/handler.rb",
    "lib/spec/matchers.rb",
    "lib/spec/matchers/be.rb",
    "lib/spec/matchers/be_close.rb",
    "lib/spec/matchers/be_instance_of.rb",
    "lib/spec/matchers/be_kind_of.rb",
    "lib/spec/matchers/change.rb",
    "lib/spec/matchers/compatibility.rb",
    "lib/spec/matchers/dsl.rb",
    "lib/spec/matchers/eql.rb",
    "lib/spec/matchers/equal.rb",
    "lib/spec/matchers/errors.rb",
    "lib/spec/matchers/exist.rb",
    "lib/spec/matchers/extensions/instance_exec.rb",
    "lib/spec/matchers/generated_descriptions.rb",
    "lib/spec/matchers/has.rb",
    "lib/spec/matchers/have.rb",
    "lib/spec/matchers/include.rb",
    "lib/spec/matchers/match.rb",
    "lib/spec/matchers/match_array.rb",
    "lib/spec/matchers/matcher.rb",
    "lib/spec/matchers/method_missing.rb",
    "lib/spec/matchers/operator_matcher.rb",
    "lib/spec/matchers/pretty.rb",
    "lib/spec/matchers/raise_error.rb",
    "lib/spec/matchers/respond_to.rb",
    "lib/spec/matchers/satisfy.rb",
    "lib/spec/matchers/simple_matcher.rb",
    "lib/spec/matchers/throw_symbol.rb",
    "lib/spec/matchers/wrap_expectation.rb",
    "spec/spec.opts",
    "spec/spec/expectations/differs/default_spec.rb",
    "spec/spec/expectations/extensions/kernel_spec.rb",
    "spec/spec/expectations/fail_with_spec.rb",
    "spec/spec/expectations/handler_spec.rb",
    "spec/spec/expectations/wrap_expectation_spec.rb",
    "spec/spec_helper.rb",
    "spec/suite.rb",
    "spec/support/macros.rb"
  ]
  s.homepage = %q{http://github.com/rspec/expectations}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{rspec expectations (should[_not] and matchers)}
  s.test_files = [
    "spec/spec/expectations/differs/default_spec.rb",
    "spec/spec/expectations/extensions/kernel_spec.rb",
    "spec/spec/expectations/fail_with_spec.rb",
    "spec/spec/expectations/handler_spec.rb",
    "spec/spec/expectations/wrap_expectation_spec.rb",
    "spec/spec_helper.rb",
    "spec/suite.rb",
    "spec/support/macros.rb"
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
