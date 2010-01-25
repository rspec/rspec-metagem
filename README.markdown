# RSpec Core

rspec-core includes the runner, output formatters, and the `rspec` command.

rspec-core is currently in alpha release. While you are welcome to track, fork,
explore, etc, we're too early in the process to start fielding pull requests
and or issues from outside the core development team, so please don't waste
your time until this notice changes.

## Install

    [sudo] gem install rspec --prerelease

This will install rspec, rspec-core, rspec-expectations and rspec-mocks.

## Known Issues

### Ruby-1.9

Due to changes in scoping rules in 1.9, classes defined inside example groups
are not visible to the examples. For example:

    describe "something" do
      class Foo
      end

      it "does something" do
        Foo.new
      end
    end

This runs without incident in ruby-1.8, but raises an `uninitialized constant`
error in ruby-1.9. We had solved this in rspec-1.x, but rspec-2 has a slightly
different object model, so this has (for the moment) reared its ugly head. We'll
certainly resolve this before rspec-core-2.0.0 (final) is released. 

You can, of course, fully qualify the declaration and everything works fine:

    describe "something" do
      class ::Foo
      end

      it "does something" do
        Foo.new
      end
    end

#### Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
* [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

