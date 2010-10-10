# Upgrade to rspec-core-2.0

## What's changed since RSpec-1

### rspec command

The command to run specs is now `rspec` instead of `spec`.

    rspec ./spec

#### Co-habitation of rspec-1 and rspec-2

Early beta versions of RSpec-2 included a `spec` command, which conflicted with
the RSpec-1 `spec` command because RSpec-1's was installed by the rspec gem,
while RSpec-2's is installed by the rspec-core gem.

If you installed one of these early versions, the safest bet is to uninstall
rspec-1 and rspec-core-2, and then reinstall both. After you do this, you will
be able to run rspec-2 like this:

    `rspec ./spec`

... and rspec-1 like this:

    `spec _1.3.1_ ./spec`

Rubygems inspects the first argument to any gem executable to see if it's
formatted like a version number surrounded by underscores. If so, it uses that
version (e.g.  `1.3.1`). If not, it uses the most recent version (e.g.
`2.0.0`).

### rake task

The RSpec rake task has moved to:

    'rspec/core/rake_task'

RCov options are now set directly on the Rake task:

    RSpec::Core::RakeTask.new(:rcov) do |t|
      t.rcov_opts =  %q[--exclude "spec"]
    end

In RSpec-1, the rake task would read in rcov options from an `rcov.opts`
file. This is ignored by RSpec-2.

### autotest

RSpec-2 works with autotest as follows:

    rspec --configure autotest

This adds `./autotest/discover.rb` with:

    Autotest.add_discovery { "rspec2" }

Now, on the command line just type:

    autotest

Or, if you're using bundler:

    bundle exec autotest

The `autospec` command is a thing of the past. 

### RSpec is the new Spec

The root namespace (top level module) is now `RSpec` instead of `Spec`, and
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

### Bones

Bones produces a handy little Rakefile to provide several services including
running specs. The current version (3.4.7) still assumes RSpec-1. To bring its
Rakefile into conformance with RSpec-2 a few changes are necessary.

1.  The require line has changed to `require 'spec/rake/spectask'`

2.  The `spec_opts` accessor has been deprecated in favor of `rspec_opts`. Also,
    the `rspec` command no longer supports the `--options` command line option
    so the options must be embedded directly in the Rakefile, or stored in the
    `.rspec` files mentioned above.

3.  The `spec_files` accessor has been replaced by `pattern`.

Here is a complete example:

    # rspec-1
    Spec::Rake::SpecTask.new do |t|
      t.spec_opts = ['--options', "\"spec/spec.opts\""]
      t.spec_files = FileList['spec/**/*.rb']
    end

becomes:

    # rspec-2
    RSpec::Core::RakeTask.new do |t|
      t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
      t.pattern = 'spec/**/*_spec.rb'
    end

### `context` is no longer a top-level method

We removed `context` from the main object because it was creating conflicts with
IRB and some users who had `Context` domain objects. `describe` is still there,
so if you want to use `context` at the top level, just alias it:

    alias :context :describe

Of course, you can still use `context` to declare a nested group:

    describe "something" do
      context "in some context" do
        it "does something" do
          # ...
        end
      end
    end

### `$KCODE` no longer set implicitly to `'u'`

In RSpec-1, the runner set `$KCODE` to `'u'`, which impacts, among other
things, the behaviour of Regular Expressions when applied to non-ascii
characters. This is no longer the case in RSpec-2.

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
