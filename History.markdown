## rspec-expectations release history (incomplete)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.rc...v2.0.0)

* Enhancements
  * Add match_for_should_not method to matcher DSL (Myron Marston)

* Bug fixes
  * respond_to matcher works correctly with should_not with multiple methods (Myron Marston)
  * include matcher works correctly with should_not with multiple values (Myron Marston)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * require 'rspec/expectations' in a T::U or MiniUnit suite (Josep M. Bach)

* Bug fixes
  * change by 0 passes/fails correctly (Len Smith)
  * Add description to satisfy matcher

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * diffing improvements
    * diff multiline strings
    * don't diff single line strings
    * don't diff numbers (silly)
    * diff regexp + multiline string

* Bug fixes
  * should[_not] change now handles boolean values correctly
