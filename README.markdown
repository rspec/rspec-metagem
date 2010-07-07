# RSpec Expectations

rspec-expectations adds `should` and `should_not` to every object and includes
RSpec::Matchers, a library of standard matchers.

## Matchers

Matchers are objects used to compose expectations:

    result.should eq("this value")

In that example, `eq("this value")` returns a `Matcher` object that
compares the actual `result` to the expected `"this value"`.

## Contribute

See [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
