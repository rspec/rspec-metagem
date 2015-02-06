require 'rspec/support/spec/prevent_load_time_warnings'

RSpec.describe "RSpec::Expectations" do
  it_behaves_like 'a library that issues no warnings when loaded', 'rspec-expectations',
    # We define minitest constants because rspec/expectations/minitest_integration
    # expects these constants to already be defined.
    'module Minitest; class Assertion; end; module Test; end; end',
    'require "rspec/expectations"'

  it 'does not allow expectation failures to be caught by a bare rescue' do
    expect {
      expect(2).to eq(3) rescue nil
    }.to fail_including("expected: 3")
  end
end
