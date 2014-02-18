### 3.0.0.beta2 / 2014-02-17
[full changelog](http://github.com/rspec/rspec-expectations/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Remove deprecated support for accessing the `RSpec` constant using
  `Rspec` or `Spec`. (Myron Marston)
* Remove deprecated `RSpec::Expectations.differ=`. (Myron Marston)
* Remove support for deprecated `expect(...).should`. (Myron Marston)
* Explicitly disallow `expect { }.not_to change { }` with `by`,
  `by_at_least`, `by_at_most` or `to`. These have never been supported
  but did not raise explicit errors. (Myron Marston)
* Provide `===` rather than `==` as an alias of `matches?` for
  all matchers.  The semantics of `===` are closer to an RSpec
  matcher than `==`. (Myron Marston)
* Remove deprecated `RSpec::Matchers::OperatorMatcher` constant.
  (Myron Marston)
* Make `RSpec::Expectations::ExpectationNotMetError` subclass
  `Exception` rather than `StandardError` so they can bypass
  a bare `rescue` in end-user code (e.g. when an expectation is
  set from within a rspec-mocks stub implementation). (Myron Marston)
* Remove Test::Unit and Minitest 4.x integration. (Myron Marston)

Enhancements:

* Simplify the failure message of the `be` matcher when matching against:
  `true`, `false` and `nil`. (Sam Phippen)
* Update matcher protocol and custom matcher DSL to better align
  with the newer `expect` syntax. If you want your matchers to
  maintain compatibility with multiple versions of RSpec, you can
  alias the new names to the old. (Myron Marston)
    * `failure_message_for_should` => `failure_message`
    * `failure_message_for_should_not` => `failure_message_when_negated`
    * `match_for_should` => `match`
    * `match_for_should_not` => `match_when_negated`
* Improve generated descriptions from `change` matcher. (Myron Marston)
* Add support for compound matcher expressions using `and` and `or`.
  Simply chain them off of any existing matcher to create an expression
  like `expect(alphabet).to start_with("a").and end_with("z")`.
  (Eloy Espinaco)
* Add `contain_exactly` as a less ambiguous version of `match_array`.
  Note that it expects the expected array to be splatted as
  individual args: `expect(array).to contain_exactly(1, 2)` is
  the same as `expect(array).to match_array([1, 2])`. (Myron Marston)
* Update `contain_exactly`/`match_array` so that it can match against
  other non-array collections (such as a `Set`). (Myron Marston)
* Update built-in matchers so that they can accept matchers as arguments
  to allow you to compose matchers in arbitrary ways. (Myron Marston)
* Add `RSpec::Matchers::Composable` mixin that can be used to make
  a custom matcher composable as well. Note that custom matchers
  defined via `RSpec::Matchers.define` already have this. (Myron
  Marston)
* Define noun-phrase aliases for built-in matchers, which can be
  used when creating composed matcher expressions that read better
  and provide better failure messages. (Myron Marston)
* Add `RSpec::Machers.alias_matcher` so users can define their own
  matcher aliases. The `description` of the matcher will reflect the
  alternate matcher name. (Myron Marston)
* Add explicit `be_between` matcher. `be_between` has worked for a
  long time as a dynamic predicate matcher, but the failure message
  was suboptimal. The new matcher provides a much better failure
  message. (Erik Michaels-Ober)
* Enhance the `be_between` matcher to allow for `inclusive` or `exclusive`
  comparison (e.g. inclusive of min/max or exclusive of min/max).
  (Pedro Gimenez)
* Make failure message for `not_to be #{operator}` less confusing by
  only saying it's confusing when comparison operators are used.
  (Prathamesh Sonpatki)
* Improve failure message of `eq` matcher when `Time` or `DateTime`
  objects are used so that the full sub-second precision is included.
  (Thomas Holmes, Jeff Wallace)
* Add `output` matcher for expecting that a block outputs `to_stdout`
  or `to_stderr`. (Luca Pette, Matthias Günther)
* Forward a provided block on to the `has_xyz?` method call when
  the `have_xyz` matcher is used. (Damian Galarza)
* Provide integration with Minitest 5.x. Require
  `rspec/expectations/minitest_integration` after loading minitest
  to use rspec-expectations with minitest. (Myron Marston)

Bug Fixes:

* Fix wrong matcher descriptions with falsey expected value (yujinakayama)
* Fix `expect { }.not_to change { }.from(x)` so that the matcher only
  passes if the starting value is `x`. (Tyler Rick, Myron Marston)
* Fix hash diffing, so that it colorizes properly and doesn't consider trailing
  commas when performing the diff. (Jared Norman)
* Fix built-in matchers to fail normally rather than raising
  `ArgumentError` when given an object of the wrong type to match
  against, so that they work well in composite matcher expressions like
  `expect([1.51, "foo"]).to include(a_string_matching(/foo/), a_value_within(0.1).of(1.5))`.
  (Myron Marston)

Deprecations:

* Retain support for RSpec 2 matcher protocol (e.g. for matchers
  in 3rd party extension gems like `shoulda`), but it will print
  a deprecation warning. (Myron Marston)

### 3.0.0.beta1 / 2013-11-07
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.beta1...v3.0.0.beta1)

Breaking Changes for 3.0.0:

* Remove explicit support for 1.8.6. (Jon Rowe)
* Remove the deprecated `be_close` matcher, preferring `be_within` instead.
  (Sam Phippen)
* Remove the deprecated `have`, `have_at_least` and `have_at_most` matchers.
  You can continue using those matchers through https://github.com/rspec/rspec-collection_matchers,
  or you can rewrite your expectations with something like 
  `expect(your_object.size).to eq(num)`. (Hugo Baraúna)
* Rename `be_true` and `be_false` to `be_truthy` and `be_falsey`. (Sam Phippen)
* Make `expect { }.to_not raise_error(SomeSpecificClass, message)`,
       `expect { }.to_not raise_error(SomeSpecificClass)` and
       `expect { }.to_not raise_error(message)` invalid, since they are prone
  to hiding failures. Instead, use `expect { }.to_not raise_error` (with no
  args). (Sam Phippen)
* Within `RSpec::Matchers.define` blocks, helper methods made available
  either via `def self.helper` or `extend HelperModule` are no longer
  available to the `match` block (or any of the others). Instead
  `include` your helper module and define the helper method as an
  instance method. (Myron Marston)
* Force upgrading Diff::LCS for encoding compatbility with diffs. (Jon Rowe)

Enhancements:

* Support `do..end` style block with `raise_error` matcher. (Yuji Nakayama)
* Rewrote custom matcher DSL to simplify its implementation and solve a
  few issues. (Myron Marston)
* Allow early `return` from within custom matcher DSL blocks. (Myron
  Marston)
* The custom matcher DSL's `chain` can now accept a block. (Myron
  Marston)
* Support setting an expectation on a `raise_error` matcher via a chained
  `with_message` method call. (Sam Phippen)

Bug Fixes:

* Allow `include` and `match` matchers to be used from within a
  DSL-defined custom matcher's `match` block. (Myron Marston)
* Correct encoding error message on diff failure (Jon Rowe)

Deprecations:

 * Using the old `:should` syntax without explicitly configuring it is deprecated.
   It will continue to work but will emit a deprecation warning in RSpec 3 if
   you do not explicitly enable it. (Sam Phippen)

### 2.99.0.beta2 / 2014-02-17
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.beta1...v2.99.0.beta2)

Deprecations:

* Deprecate chaining `by`, `by_at_least`, `by_at_most` or `to` off of
  `expect { }.not_to change { }`. The docs have always said these are
  not supported for the negative form but now they explicitly raise
  errors in RSpec 3. (Myron Marston)
* Change the semantics of `expect { }.not_to change { x }.from(y)`.
  In RSpec 2.x, this expectation would only fail if `x` started with
  the value of `y` and changed. If it started with a different value
  and changed, it would pass. In RSpec 3, it will pass only if the
  value starts at `y` and it does not change. (Myron Marston)
* Deprecate `matcher == value` as an alias for `matcher.matches?(value)`,
  in favor of `matcher === value`. (Myron Marston)
* Deprecate `RSpec::Matchers::OperatorMatcher` in favor of
  `RSpec::Matchers::BuiltIn::OperatorMatcher`. (Myron Marston)
* Deprecate auto-integration with Test::Unit and minitest.
  Instead, include `RSpec::Matchers` in the appropriate test case
  base class yourself. (Myron Marston)
* Deprecate treating `#expected` on a DSL-generated custom matcher
  as an array when only 1 argument is passed to the matcher method.
  In RSpec 3 it will be the single value in order to make diffs
  work properly. (Jon Rowe)

### 2.99.0.beta1 / 2013-11-07
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.4...v2.99.0.beta1)

Deprecations

* Deprecate `have`, `have_at_least` and `have_at_most`. You can continue using those
	matchers through https://github.com/rspec/rspec-collection_matchers, or
	you can rewrite your expectations with something like
	`expect(your_object.size).to eq(num)`. (Hugo Baraúna)
* Deprecate `be_xyz` predicate matcher when `xyz?` is a private method.
  (Jon Rowe)
* Deprecate `be_true`/`be_false` in favour of `be_truthy`/`be_falsey`
  (for Ruby's conditional semantics) or `be true`/`be false`
  (for exact equality). (Sam Phippen)
* Deprecate calling helper methods from a custom matcher with the wrong
  scope. (Myron Marston)
  * `def self.foo` / `extend Helper` can be used to add macro methods
    (e.g. methods that call the custom matcher DSL methods), but should
    not be used to define helper methods called from within the DSL
    blocks.
  * `def foo` / `include Helper` is the opposite: it's for helper methods
    callable from within a DSL block, but not for defining macros.
  * RSpec 2.x allowed helper methods defined either way to be used for
    either purpose, but RSpec 3.0 will not.

### 2.14.5 / 2014-02-01
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.4...v2.14.5)

Bug fixes

* Fix wrong matcher descriptions with falsey expected value
  (yujinakayama)

### 2.14.4 / 2013-11-06
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.3...v2.14.4)

Bug fixes

* Make the `match` matcher produce a diff output. (Jon Rowe, Ben Moss)
* Choose encoding for diff's more intelligently, and when all else fails fall
  back to default internal encoding with replacing characters. (Jon Rowe)

### 2.14.3 / 2013-09-22
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.2...v2.14.3)

Bug fixes

* Fix operator matchers (`should` syntax) when `method` is redefined on target.
  (Brandon Turner)
* Fix diffing of hashes with object based keys. (Jon Rowe)
* Fix operator matchers (`should` syntax) when operator is defined via
  `method_missing` (Jon Rowe)

### 2.14.2 / 2013-08-14
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.1...v2.14.2)

Bug fixes

* Fix `be_<predicate>` matcher to not support operator chaining like the
  `be` matcher does (e.g. `be == 5`). This led to some odd behaviors
  since `be_<predicate> == anything` returned a `BeComparedTo` matcher
  and was thus always truthy. This was a consequence of the implementation
  (e.g. subclassing the basic `Be` matcher) and was not intended behavior.
  (Myron Marston).
* Fix `change` matcher to compare using `==` in addition to `===`. This
  is important for an expression like:
  `expect {}.to change { a.class }.from(ClassA).to(ClassB)` because
  `SomeClass === SomeClass` returns false. (Myron Marston)

### 2.14.1 / 2013-08-08
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.0...2.14.1)

Bug fixes

* Ensure diff output uses the same encoding as the encoding of
  the string being diff'd to prevent `Encoding::UndefinedConversionError`
  errors (Jon Rowe).

### 2.14.0 / 2013-07-06
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.0.rc1...v2.14.0)

Bug fixes

* Values that are not matchers use `#inspect`, rather than `#description` for
  documentation output (Andy Lindeman, Sam Phippen).
* Make `expect(a).to be_within(x).percent_of(y)` work with negative y
  (Katsuhiko Nishimra).
* Make the `be_predicate` matcher work as expected used with `expect{...}.to
  change...`  (Sam Phippen).

### 2.14.0.rc1 / 2013-05-27
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.13.0...v2.14.0.rc1)

Enhancements

* Enhance `yield_control` so that you can specify an exact or relative
  number of times: `expect { }.to yield_control.exactly(3).times`,
  `expect { }.to yield_control.at_least(2).times`, etc (Bartek
  Borkowski).
* Make the differ that is used when an expectation fails better handle arrays
  by splitting each element of the array onto its own line. (Sam Phippen)
* Accept duck-typed strings that respond to `:to_str` as expectation messages.
  (Toby Ovod-Everett)

Bug fixes

* Fix differ to not raise errors when dealing with differently-encoded
  strings (Jon Rowe).
* Fix `expect(something).to be_within(x).percent_of(y)` where x and y are both
  integers (Sam Phippen).
* Fix `have` matcher to handle the fact that on ruby 2.0,
  `Enumerator#size` may return nil (Kenta Murata).
* Fix `expect { raise s }.to raise_error(s)` where s is an error instance
  on ruby 2.0 (Sam Phippen).
* Fix `expect(object).to raise_error` passing. This now warns the user and
  fails the spec (tomykaira).

Deprecations

* Deprecate `expect { }.not_to raise_error(SpecificErrorClass)` or
  `expect { }.not_to raise_error("some specific message")`. Using
  these was prone to hiding failures as they would allow _any other
  error_ to pass. (Sam Phippen and David Chelimsky)

### 2.13.0 / 2013-02-23
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.12.1...v2.13.0)

Enhancements

* Add support for percent deltas to `be_within` matcher:
  `expect(value).to be_within(10).percent_of(expected)`
  (Myron Marston).
* Add support to `include` matcher to allow it to be given a list
  of matchers as the expecteds to match against (Luke Redpath).

Bug fixes

* Fix `change` matcher so that it dups strings in order to handle
  mutated strings (Myron Marston).
* Fix `should be =~ /some regex/` / `expect(...).to be =~ /some regex/`.
  Previously, these either failed with a confusing `undefined method
  matches?' for false:FalseClass` error or were no-ops that didn't
  actually verify anything (Myron Marston).
* Add compatibility for diff-lcs 1.2 and relax the version
  constraint (Peter Goldstein).
* Fix DSL-generated matchers to allow multiple instances of the
  same matcher in the same example to have different description
  and failure messages based on the expected value (Myron Marston).
* Prevent `undefined method #split for Array` error when dumping
  the diff of an array of multiline strings (Myron Marston).
* Don't blow up when comparing strings that are in an encoding
  that is not ASCII compatible (Myron Marston).
* Remove confusing "Check the implementation of #==" message
  printed for empty diffs (Myron Marston).

### 2.12.1 / 2012-12-15
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.12.0...v2.12.1)

Bug fixes

* Improve the failure message for an expression like
  `{}.should =~ {}`. (Myron Marston and Andy Lindeman)
* Provide a `match_regex` alias so that custom matchers
  built using the matcher DSL can use it (since `match`
  is a different method in that context).
  (Steven Harman)

### 2.12.0 / 2012-11-12
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.11.3...v2.12.0)

Enhancements

* Colorize diffs if the `--color` option is configured. (Alex Coplan)
* Include backtraces in unexpected errors handled by `raise_error`
  matcher (Myron Marston)
* Print a warning when users accidentally pass a non-string argument
  as an expectation message (Sam Phippen)
* `=~` and `match_array` matchers output a more useful error message when
  the actual value is not an array (or an object that responds to `#to_ary`)
  (Sam Phippen)

Bug fixes

* Fix `include` matcher so that `expect({}).to include(:a => nil)`
  fails as it should (Sam Phippen).
* Fix `be_an_instance_of` matcher so that `Class#to_s` is used in the
  description rather than `Class#inspect`, since some classes (like
  `ActiveRecord::Base`) define a long, verbose `#inspect`.
  (Tom Stuart)

### 2.11.3 / 2012-09-04
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.11.2...v2.11.3)

Bug fixes

* Fix (and deprecate) `expect { }.should` syntax so that it works even
  though it was never a documented or intended syntax. It worked as a
  consequence of the implementation of `expect` in RSpec 2.10 and
  earlier. (Myron Marston)
* Ensure #== is defined on built in matchers so that they can be composed.
  For example:

    expect {
      user.emailed!
    }.to change { user.last_emailed_at }.to be_within(1.second).of(Time.zone.now)

### 2.11.2 / 2012-07-25
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.11.1...v2.11.2)

Bug fixes

* Define `should` and `should_not` on `Object` rather than `BasicObject`
  on MacRuby. On MacRuby, `BasicObject` is defined but is not the root
  of the object hierarchy. (Gabriel Gilder)

### 2.11.1 / 2012-07-08
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.11.0...v2.11.1)

Bug fixes

* Constrain `actual` in `be_within` matcher to values that respond to `-` instead
  of requiring a specific type.
    * `Time`, for example, is a legit alternative.

### 2.11.0 / 2012-07-07
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.10.0...v2.11.0)

Enhancements

* Expand `expect` syntax so that it supports expections on bare values
  in addition to blocks (Myron Marston).
* Add configuration options to control available expectation syntaxes
  (Myron Marston):
  * `RSpec.configuration.expect_with(:rspec) { |c| c.syntax = :expect }`
  * `RSpec.configuration.expect_with(:rspec) { |c| c.syntax = :should }`
  * `RSpec.configuration.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }`
  * `RSpec.configuration.add_should_and_should_not_to Delegator`

Bug fixes

* Allow only `Numeric` values to be the "actual" in the `be_within` matcher.
  This prevents confusing error messages. (Su Zhang @zhangsu)
* Define `should` and `should_not` on `BasicObject` rather than `Kernel`
  on 1.9. This makes `should` and `should_not` work properly with
  `BasicObject`-subclassed proxy objects like `Delegator`. (Myron
  Marston)

### 2.10.0 / 2012-05-03
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.9.1...v2.10.0)

Enhancements

* Add new `start_with` and `end_with` matchers (Jeremy Wadsack)
* Add new matchers for specifying yields (Myron Marston):
    * `expect {...}.to yield_control`
    * `expect {...}.to yield_with_args(1, 2, 3)`
    * `expect {...}.to yield_with_no_args`
    * `expect {...}.to yield_successive_args(1, 2, 3)`
* `match_unless_raises` takes multiple exception args

Bug fixes

* Fix `be_within` matcher to be inclusive of delta.
* Fix message-specific specs to pass on Rubinius (John Firebaugh)

### 2.9.1 / 2012-04-03
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.9.0...v2.9.1)

Bug fixes

* Provide a helpful message if the diff between two objects is empty.
* Fix bug diffing single strings with multiline strings.
* Fix for error with using custom matchers inside other custom matchers
  (mirasrael)
* Fix using execution context methods in nested DSL matchers (mirasrael)

### 2.9.0 / 2012-03-17
[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.8.0...v2.9.0)

Enhancements

* Move built-in matcher classes to RSpec::Matchers::BuiltIn to reduce pollution
  of RSpec::Matchers (which is included in every example).
* Autoload files with matcher classes to improve load time.

Bug fixes

* Align `respond_to?` and `method_missing` in DSL-defined matchers.
* Clear out user-defined instance variables between invocations of DSL-defined
  matchers.
* Dup the instance of a DSL generated matcher so its state is not changed by
  subsequent invocations.
* Treat expected args consistently across positive and negative expectations
  (thanks to Ralf Kistner for the heads up)

### 2.8.0 / 2012-01-04

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.8.0.rc2...v2.8.0)

Enhancements

* Better diff output for Hash (Philippe Creux)
* Eliminate Ruby warnings (Olek Janiszewski)

### 2.8.0.rc2 / 2011-12-19

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.8.0.rc1...v2.8.0.rc2)

No changes for this release. Just releasing with the other rspec gems.

### 2.8.0.rc1 / 2011-11-06

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.7.0...v2.8.0.rc1)

Enhancements

* Use classes for the built-in matchers (they're faster).
* Eliminate Ruby warnings (Matijs van Zuijlen)

### 2.7.0 / 2011-10-16

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.6.0...v2.7.0)

Enhancements

* `HaveMatcher` converts argument using `to_i` (Alex Bepple & Pat Maddox)
* Improved failure message for the `have_xxx` matcher (Myron Marston)
* `HaveMatcher` supports `count` (Matthew Bellantoni)
* Change matcher dups `Enumerable` before the action, supporting custom
  `Enumerable` types like `CollectionProxy` in Rails (David Chelimsky)

Bug fixes

* Fix typo in `have(n).xyz` documentation (Jean Boussier)
* fix `safe_sort` for ruby 1.9.2 (`Kernel` now defines `<=>` for Object) (Peter
  van Hardenberg)

### 2.6.0 / 2011-05-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.5.0...v2.6.0)

Enhancements

* `change` matcher accepts regexps (Robert Davis)
* better descriptions for `have_xxx` matchers (Magnus Bergmark)
* `range.should cover(*values)` (Anders Furseth)

Bug fixes

* Removed non-ascii characters that were choking rcov (Geoffrey Byers)
* change matcher dups arrays and hashes so their before/after states can be
  compared correctly.
* Fix the order of inclusion of RSpec::Matchers in Test::Unit::TestCase and
  MiniTest::Unit::TestCase to prevent a SystemStackError (Myron Marston)

### 2.5.0 / 2011-02-05

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.4.0...v2.5.0)

Enhancements

* `should exist` works with `exist?` or `exists?` (Myron Marston)
* `expect { ... }.not_to do_something` (in addition to `to_not`)

Documentation

* improved docs for raise_error matcher (James Almond)

### 2.4.0 / 2011-01-02

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.3.0...v2.4.0)

No functional changes in this release, which was made to align with the
rspec-core-2.4.0 release.

Enhancements

* improved RDoc for change matcher (Jo Liss)

### 2.3.0 / 2010-12-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.2.1...v2.3.0)

Enhancements

* diff strings when include matcher fails (Mike Sassak)

### 2.2.0 / 2010-11-28

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.1.0...v2.2.0)

### 2.1.0 / 2010-11-07

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.1...v2.1.0)

Enhancements

* `be_within(delta).of(expected)` matcher (Myron Marston)
* Lots of new Cucumber features (Myron Marston)
* Raise error if you try `should != expected` on Ruby-1.9 (Myron Marston)
* Improved failure messages from `throw_symbol` (Myron Marston)

Bug fixes

* Eliminate hard dependency on `RSpec::Core` (Myron Marston)
* `have_matcher` - use pluralize only when ActiveSupport inflections are indeed
  defined (Josep M Bach)
* throw_symbol matcher no longer swallows exceptions (Myron Marston)
* fix matcher chaining to avoid name collisions (Myron Marston)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.rc...v2.0.0)

Enhancements

* Add match_for_should_not method to matcher DSL (Myron Marston)

Bug fixes

* `respond_to` matcher works correctly with `should_not` with multiple methods
  (Myron Marston)
* `include` matcher works correctly with `should_not` with multiple values
  (Myron Marston)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.22...v2.0.0.rc)

Enhancements

* `require 'rspec/expectations'` in a T::U or MiniUnit suite (Josep M. Bach)

Bug fixes

* change by 0 passes/fails correctly (Len Smith)
* Add description to satisfy matcher

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.20...v2.0.0.beta.22)

Enhancements

* diffing improvements
    * diff multiline strings
    * don't diff single line strings
    * don't diff numbers (silly)
    * diff regexp + multiline string

Bug fixes
    * `should[_not]` change now handles boolean values correctly
