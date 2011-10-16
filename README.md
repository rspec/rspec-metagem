# rspec-core

RSpec Core provides the structure for writing executable examples of how your
code should behave.

## Install

    gem install rspec      # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-core # for rspec-core only

## Upgrading from rspec-1.x

See [features/Upgrade.md](http://github.com/rspec/rspec-core/blob/master/features/Upgrade.md)

## Get Started

Start with a simple example of behavior you expect from your system. Do
this before you write any implementation code:

    # in spec/calculator_spec.rb
    describe Calculator do
      it "add(x,y) returns the sum of its arguments" do
        Calculator.new.add(1, 2).should eq(3)
      end
    end

Run this with the rspec command, and watch it fail:

    $ rspec spec/calculator_spec.rb
    ./spec/calculator_spec.rb:1: uninitialized constant Calculator

Implement the simplest solution:

    # in lib/calculator.rb
    class Calculator
      def add(a,b)
        a + b
      end
    end

Be sure to require the implementation file in the spec:

    # in spec/calculator_spec.rb
    # - RSpec adds ./lib to the $LOAD_PATH
    require "calculator"

Now run the spec again, and watch it pass:

    $ rspec spec/calculator_spec.rb
    .

    Finished in 0.000315 seconds
    1 example, 0 failures

Use the `documentation` formatter to see the resulting spec:

    $ rspec spec/calculator_spec.rb --format doc
    Calculator add
      returns the sum of its arguments

    Finished in 0.000379 seconds
    1 example, 0 failures

## See also

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
