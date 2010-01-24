# RSpec Core

See README.markdown at [http://github.com/rspec/meta](http://github.com/rspec/meta)

#### Also see

* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)

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
