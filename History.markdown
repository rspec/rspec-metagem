## rspec-expectations release history (incomplete)

### 2.0.0.beta.23 / not yet released

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.22...master)

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
