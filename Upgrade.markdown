# Upgrade to rspec-core-2.0

## What's changed since rspec-1

### rspec command

The command to run specs is now `rspec` instead of `spec`.

    rspec ./spec

### rake task

The RSpec rake task has moved to:

    'rspec/core/rake_task'

### autotest

RSpec-2 works with autotest as follows:

    rspec --configure autotest

This adds `./autotest/discover.rb` with:

    Autotest.add_discovery { "rspec2" }

Now, on the command line just type:

    $ autotest

Or, if you're using bundler:

    $ bundle exec autotest

The `autospec` command is a thing of the past. 

### RSpec

The root namespace (top level module ) is now `RSpec` instead of `Spec`, and
the root directory under `lib` within all of the `rspec` gems is `rspec` instead of `spec`.

### Configuration

Typically in `spec/spec_helper.rb`, configuration is now done like this:

    RSpec.configure do |c|
      # ....
    end

### .rspec

Command line options can be persisted in a `.rspec` file in a project. You
can also store a `.rspec` file in your home directory (`~/.rspec`) with global
options. Precedence is:

    command line
    ./.rspec
    ~/.rspec

## What's new

### Runner

The new runner for rspec-2 comes from Micronaut.

### Metadata!

In rspec-2, every example and example group comes with metadata information
like the file and line number on which it was declared, the arguments passed to
`describe` and `it`, etc.  This metadata can be appended to through a hash
argument passed to `describe` or `it`, allowing us to pre and post-process
each example in a variety of ways.

### Filtering

The most obvious use is for filtering the run. For example:

    # in spec/spec_helper.rb
    RSpec.configure do |c|
      c.filter_run :focus => true
    end

    # in any spec file
    describe "something" do
      it "does something", :focus => true do
        # ....
      end
    end

When you run the `rspec` command, rspec will run only the examples that have
`:focus => true` in the hash. 

You can also add `run_all_when_everything_filtered` to the config:

    RSpec.configure do |c|
      c.filter_run :focus => true
      c.run_all_when_everything_filtered = true
    end

Now if there are no examples tagged with `:focus => true`, all examples
will be run. This makes it really easy to focus on one example for a
while, but then go back to running all of the examples by removing that
argument from `it`. Works with `describe` too, in which case it runs
all of the examples in that group.

The configuration will accept a lambda, which provides a lot of flexibility
in filtering examples. Say, for example, you have a spec for functionality that
behaves slightly differently in Ruby 1.8 and Ruby 1.9. We have that in
rspec-core, and here's how we're getting the right stuff to run under the
right version:

    # in spec/spec_helper.rb
    RSpec.configure do |c|
      c.exclusion_filter = { :ruby => lambda {|version|
        !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
      }}
    end

    # in any spec file
    describe "something" do
      it "does something", :ruby => 1.8 do
        # ....
      end

      it "does something", :ruby => 1.9 do
        # ....
      end
    end

In this case, we're using `exclusion_filter` instead of `filter_run` or
`filter`, which indicate _inclusion_ filters. So each of those examples is
excluded if we're _not_ running the version of Ruby they work with.

### Shared example groups

Shared example groups are now run in a nested group within the including group
(they used to be run in the same group). Nested groups inherit `before`, `after`,
`around`, and `let` hooks, as well as any methods that are defined in the parent
group.

This new approach provides better encapsulation, better output, and an
opportunity to add contextual information to the shared group via a block
passed to `it_should_behave_like`.

See [features/example\_groups/shared\_example\_group.feature](http://github.com/rspec/rspec-core/blob/master/features/example_groups/shared_example_group.feature) for more information.

NOTICE: The including example groups no longer have access to any of the
methods, hooks, or state defined inside a shared group. This will break specs
that were using shared example groups to extend the behavior of including
groups in any way besides their intended purpose: to add examples to a group.
