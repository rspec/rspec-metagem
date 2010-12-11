rspec-core provides the structure for RSpec code examples:

    describe Account do
      it "has a balance of zero when first opened" do
        # example code goes here - for more on the 
        # code inside the examples, see rspec-expectations 
        # and rspec-mocks
      end
    end

### Autotest integration

RSpec ships with a specialized subclass of Autotest. You can pass the --style
option to the autotest command to tell Autotest to load this subclass:

    $ autotest --style rspec2

Alternatively, you can configure your project such that this happens
automatically, in which case you can just type:

    $ autotest

Here's how:

#### rspec-2.3 and up

Add a .rspec file to the project's root directory if it's not already there.
You can use this to configure RSpec options, but you don't have to. As long as
RSpec sees this file, it will tell Autotest to use the "rspec2" style.

#### rspec-2.2 and down

Add an autotest directory to the project root, and add a file named discover.rb to
that directory with the following:

    # in ./autotest/discover.rb
    Autotest.add_discovery {"rspec2"}

## Issues

The documentation for rspec-core is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-core/issues) or a [pull
request](http://github.com/rspec/rspec-core).
