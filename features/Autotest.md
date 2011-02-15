RSpec ships with a specialized subclass of Autotest. To use it, just add a
`.rspec` file to your project's root directory, and run the `autotest` command
as normal:

    $ autotest

### Bundler

The `autotest` command generates a shell command that runs your specs. If you
are using Bundler, and you want the shell command to include `bundle exec`,
require the Autotest bundler plugin in a `.autotest` file in the project's root
directory or your home directory:

    # in .autotest
    require "autotest/bundler"

### Upgrading from previous versions of rspec

Previous versions of RSpec used a different mechanism for telling autotest to
invoke RSpec's Autotest extension: it generated an `autotest/discover.rb` file
in the project's root directory. This is no longer necessary with the new
approach of RSpec looking for a `.rspec` file, so feel free to delete the
`autotest/discover.rb` file in the project root if you have one.
