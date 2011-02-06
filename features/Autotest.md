RSpec ships with a specialized subclass of Autotest. To tell RSpec to tell
Autotest to use RSpec's extension, just add a `.rspec` file to your project's
root directory. Then, just type:

    $ autotest

### Bundler

If you are using Bundler in your app, and you want the shell command to include
`bundle exec`, require the Autotest bundler plugin in a `.autotest` file in the project's
root directory or your home directory:

    # in .autotest
    require "autotest/bundler"
