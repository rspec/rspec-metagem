# RSpec Expectations

RSpec::Expectations lets you express expected outcomes on an object in an
example.

    account.balance.should eq(Money.new(37.42, :USD))

## Install

If you want to use rspec-expectations with rspec, just install the rspec gem
and RubyGems will also install rspec-expectations for you (along with
rspec-core and rspec-mocks):

    gem install rspec

If you want to use rspec-expectations with another tool, like Test::Unit,
Minitest, or Cucumber, you can install it directly:

    gem install rspec-expectations

## Basic usage

Here's an example using rspec-core:

```ruby
describe Order do
  it "sums the prices of the items in its line items" do
    order = Order.new
    order.add_entry(LineItem.new(:item => Item.new(
      :price => Money.new(1.11, :USD)
    )))
    order.add_entry(LineItem.new(:item => Item.new(
      :price => Money.new(2.22, :USD),
      :quantity => 2
    )))
    order.total.should eq(Money.new(5.55, :USD))
  end
end
```

The `describe` and `it` methods come from rspec-core.  The `Order`, `LineItem`,
and `Item` classes would be from _your_ code. The last line of the example
expresses an expected outcome. If `order.total == Money.new(5.55, :USD)`, then
the example passes. If not, it fails with a message like:

    expected: #<Money @value=5.55 @currency=:USD>
         got: #<Money @value=1.11 @currency=:USD>

## Built-in matchers

### Equivalence

```ruby
actual.should eq(expected)  # passes if actual == expected
actual.should == expected   # passes if actual == expected
actual.should eql(expected) # passes if actual.eql?(expected)
```

### Identity

```ruby
actual.should be(expected)    # passes if actual.equal?(expected)
actual.should equal(expected) # passes if actual.equal?(expected)
```
    
### Comparisons

```ruby
actual.should be >  expected
actual.should be >= expected
actual.should be <= expected
actual.should be <  expected
actual.should be_within(delta).of(expected)
```

### Regular expressions

```ruby
actual.should =~ /expression/
actual.should match(/expression/)
```

### Types/classes

```ruby
actual.should be_an_instance_of(expected)
actual.should be_a_kind_of(expected)
```

### Truthiness

```ruby
actual.should be_true  # passes if actual is truthy (not nil or false)
actual.should be_false # passes if actual is falsy (nil or false)
actual.should be_nil   # passes if actual is nil
```

### Expecting errors

```ruby
expect { ... }.to raise_error
expect { ... }.to raise_error(ErrorClass)
expect { ... }.to raise_error("message")
expect { ... }.to raise_error(ErrorClass, "message")
```

### Expecting throws

```ruby
expect { ... }.to throw_symbol
expect { ... }.to throw_symbol(:symbol)
expect { ... }.to throw_symbol(:symbol, 'value')
```

### Yielding

```ruby
expect { |b| 5.tap(&b) }.to yield_control # passes regardless of yielded args

expect { |b| yield_if_true(true, &b) }.to yield_with_no_args # passes only if no args are yielded

expect { |b| 5.tap(&b) }.to yield_with_args(5)
expect { |b| 5.tap(&b) }.to yield_with_args(Fixnum)
expect { |b| "a string".tap(&b) }.to yield_with_args(/str/)

expect { |b| [1, 2, 3].each(&b) }.to yield_successive_args(1, 2, 3)
expect { |b| { :a => 1, :b => 2 }.each(&b) }.to yield_successive_args([:a, 1], [:b, 2])
```

### Predicate matchers

```ruby
actual.should be_xxx         # passes if actual.xxx?
actual.should have_xxx(:arg) # passes if actual.has_xxx?(:arg)
```

### Ranges (Ruby >= 1.9 only)

```ruby
(1..10).should cover(3)
```

### Collection membership

```ruby
actual.should include(expected)
actual.should start_with(expected)
actual.should end_with(expected)
```

#### Examples

```ruby
[1,2,3].should include(1)
[1,2,3].should include(1, 2)
[1,2,3].should start_with(1)
[1,2,3].should start_with(1,2)
[1,2,3].should end_with(3)
[1,2,3].should end_with(2,3)
{:a => 'b'}.should include(:a => 'b')
"this string".should include("is str")
"this string".should start_with("this")
"this string".should end_with("ring")
```

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
