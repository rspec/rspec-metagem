## rspec-core release history (incomplete)

### 2.0.0.beta.21 (not yet released)

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.beta.20...v2.0.0.beta.21)

* Enhancements
  * CTRL-C stops the run (almost) immediately
    * first it cleans things up by running the appropriate after(:all) and after(:suite) hooks
    * then it reports on any examples that have already run
  * cleaned up rake task
    * generate correct task under variety of conditions
    * options are more consistent
    * deprecated redundant options
  * run 'bundle exec autotest' when Gemfile is present
  * support ERB in .rspec options files (Justin Ko)
  * depend on bundler for development tasks (Myron Marsten)
  * add example_group_finished to formatters and reporter (Roman Chernyatchik)

* Bug fixes
  * support paths with spaces when using autotest (Andreas Neuhaus)
  * fix module_exec with ruby 1.8.6 (Myron Marsten)
  * remove context method from top-level
    * was conflicting with irb, for example
  * errors in before(:all) are now reported correctly (Chad Humphries)
