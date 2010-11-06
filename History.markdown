## rspec-core release history (incomplete)

### 2.0.1 / 2010-10-18

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0...v2.0.1)

* Bug fixes
  * restore color when using spork + autotest
  * Pending examples without docstrings render the correct message (Josep M. Bach)
  * Fixed bug where a failure in a spec file ending in anything but _spec.rb would
    fail in a confusing way.
  * Support backtrace lines from erb templates in html formatter (Alex Crichton)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.rc...v2.0.0)

* RSpec-1 compatibility
  * Rake task uses ENV["SPEC"] as file list if present

* Bug fixes
  * Bug Fix: optparse --out foo.txt (Leonardo Bessa)
  * Suppress color codes for non-tty output (except autotest)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * implicitly require unknown formatters so you don't have to require the
    file explicitly on the commmand line (Michael Grosser) 
  * add --out/-o option to assign output target
  * added fail_fast configuration option to abort on first failure
  * support a Hash subject (its([:key]) { should == value }) (Josep M. Bach)

* Bug fixes
  * Explicitly require rspec version to fix broken rdoc task (Hans de Graaff)
  * Ignore backtrace lines that come from other languages, like Java or
    Javascript (Charles Lowell)
  * Rake task now does what is expected when setting (or not setting)
    fail_on_error and verbose
  * Fix bug in which before/after(:all) hooks were running on excluded nested
    groups (Myron Marston)
  * Fix before(:all) error handling so that it fails examples in nested groups,
    too (Myron Marston)

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * removed at_exit hook
  * CTRL-C stops the run (almost) immediately
    * first it cleans things up by running the appropriate after(:all) and after(:suite) hooks
    * then it reports on any examples that have already run
  * cleaned up rake task
    * generate correct task under variety of conditions
    * options are more consistent
    * deprecated redundant options
  * run 'bundle exec autotest' when Gemfile is present
  * support ERB in .rspec options files (Justin Ko)
  * depend on bundler for development tasks (Myron Marston)
  * add example_group_finished to formatters and reporter (Roman Chernyatchik)

* Bug fixes
  * support paths with spaces when using autotest (Andreas Neuhaus)
  * fix module_exec with ruby 1.8.6 (Myron Marston)
  * remove context method from top-level
    * was conflicting with irb, for example
  * errors in before(:all) are now reported correctly (Chad Humphries)

* Removals
  * removed -o --options-file command line option
    * use ./.rspec and ~/.rspec
