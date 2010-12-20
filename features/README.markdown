rspec-expectations is used to set expectations in executable examples.

    describe Account do
      it "has a balance of zero when first created" do
        Account.new.balance.should eq(Money.new(0))
      end
    end

## should and should_not

rspec-expectations adds `should` and `should_not` to every object. Each of
these can accept a matcher and, in most cases, an optional custom failure
message (see [customized
message](/rspec/rspec-expectations/v/2-3/customized-message)).

## Matchers

A Matcher is any object that responds to the following methods:

    matches?(actual)
    failure_message_for_should

These methods are also part of the matcher protocol, but are optional:

    does_not_match?(actual)
    failure_message_for_should_not
    description

RSpec ships with a number of [built-in
matchers](/rspec/rspec-expectations/v/2-3/dir/built-in-matchers) and a DSL for
writing your own [custom
matchers](/rspec/rspec-expectations/v/2-3/dir/custom-matchers).

## Issues

The documentation for rspec-expectations is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-expectations/issues) or a [pull
request](http://github.com/rspec/rspec-expectations).
