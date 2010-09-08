## Woefully incomplete (but gotta start somewhere)

### git (since beta.20)

* enhancements
  * cleaned up rake task
    * generate correct task under variety of conditions
    * options are more consistent
    * deprecated redundant options
  * run 'bundle exec autotest' when Gemfile is present
  * support ERB in .rspec options files (Justin Ko)
  * depend on bundler for development tasks (Myron Marsten)
  * add example_group_finished to formatters and reporter (Roman Chernyatchik)

* bug fixes
  * support paths with spaces when using autotest (Andreas Neuhaus)
  * fix module_exec with ruby 1.8.6
  * remove context method from top-level
    * was conflicting with irb, for example
  * errors in before(:all) are now reported correctly (Chad Humphries)
