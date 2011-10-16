# RSpec Expectations

rspec-expectations adds `should` and `should_not` to every object and includes
several standard matchers in RSpec::Matchers

## Install

    gem install rspec               # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-expectations  # for rspec-expectations only

## Matchers

Matchers are objects used to compose expectations:

    result.should eq("this value")

In that example, `eq("this value")` returns a `Matcher` object that
compares the actual `result` to the expected `"this value"`.

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
