# Upgrade to rspec-2.0

## What's been removed

### simple_matcher

Use Rspec::Matchers.define instead. For example, if you had:

    def eat_cheese
      simple_matcher("eat cheese") do |actual|
        actual.eat?(:cheese)
      end
    end

Change it to:

    Rspec::Matchers.define :eat_cheese do
      match do |actual|
        actual.eat?(:cheese)
      end
    end

### wrap_expectation

Use Rspec::Matchers.define instead.

    Rspec::Matchers.define :eat_cheese do
      match do |actual|
        actual.should eat?(:cheese)
      end
    end

    Rspec::Matchers.define :eat_cheese do
      include MyCheesyAssertions
      match_unless_raises Test::Unit::AssertionFailedError do |actual|
        assert_eats_chesse actual
      end
    end
