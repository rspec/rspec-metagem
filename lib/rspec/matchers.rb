require 'rspec/support'
RSpec::Support.define_optimized_require_for_rspec(:matchers) { |f| require_relative(f) }

%w[
  pretty
  composable
  built_in
  generated_descriptions
  dsl
  matcher_delegator
  aliased_matcher
].each { |file| RSpec::Support.require_rspec_matchers(file) }

# RSpec's top level namespace. All of rspec-expectations is contained
# in the `RSpec::Expectations` and `RSpec::Matchers` namespaces.
module RSpec
  # RSpec::Matchers provides a number of useful matchers we use to define
  # expectations. A matcher is any object that responds to the following:
  #
  #     matches?(actual)
  #     failure_message
  #
  # These methods are also part of the matcher protocol, but are optional:
  #
  #     does_not_match?(actual)
  #     failure_message_when_negated
  #     description
  #     supports_block_expectations?
  #
  # ## Predicates
  #
  # In addition to matchers that are defined explicitly, RSpec will create
  # custom matchers on the fly for any arbitrary predicate, giving your specs a
  # much more natural language feel.
  #
  # A Ruby predicate is a method that ends with a "?" and returns true or false.
  # Common examples are `empty?`, `nil?`, and `instance_of?`.
  #
  # All you need to do is write `expect(..).to be_` followed by the predicate
  # without the question mark, and RSpec will figure it out from there.
  # For example:
  #
  #     expect([]).to be_empty     # => [].empty?() | passes
  #     expect([]).not_to be_empty # => [].empty?() | fails
  #
  # In addtion to prefixing the predicate matchers with "be_", you can also use "be_a_"
  # and "be_an_", making your specs read much more naturally:
  #
  #     expect("a string").to be_an_instance_of(String) # =>"a string".instance_of?(String) # passes
  #
  #     expect(3).to be_a_kind_of(Fixnum)        # => 3.kind_of?(Numeric)     | passes
  #     expect(3).to be_a_kind_of(Numeric)       # => 3.kind_of?(Numeric)     | passes
  #     expect(3).to be_an_instance_of(Fixnum)   # => 3.instance_of?(Fixnum)  | passes
  #     expect(3).not_to be_an_instance_of(Numeric) # => 3.instance_of?(Numeric) | fails
  #
  # RSpec will also create custom matchers for predicates like `has_key?`. To
  # use this feature, just state that the object should have_key(:key) and RSpec will
  # call has_key?(:key) on the target. For example:
  #
  #     expect(:a => "A").to have_key(:a)
  #     expect(:a => "A").to have_key(:b) # fails
  #
  # You can use this feature to invoke any predicate that begins with "has_", whether it is
  # part of the Ruby libraries (like `Hash#has_key?`) or a method you wrote on your own class.
  #
  # Note that RSpec does not provide composable aliases for these dynamic predicate
  # matchers. You can easily define your own aliases, though:
  #
  #     RSpec::Matchers.alias_matcher :a_user_who_is_an_admin, :be_an_admin
  #     expect(user_list).to include(a_user_who_is_an_admin)
  #
  # ## Custom Matchers
  #
  # When you find that none of the stock matchers provide a natural feeling
  # expectation, you can very easily write your own using RSpec's matcher DSL
  # or writing one from scratch.
  #
  # ### Matcher DSL
  #
  # Imagine that you are writing a game in which players can be in various
  # zones on a virtual board. To specify that bob should be in zone 4, you
  # could say:
  #
  #     expect(bob.current_zone).to eql(Zone.new("4"))
  #
  # But you might find it more expressive to say:
  #
  #     expect(bob).to be_in_zone("4")
  #
  # and/or
  #
  #     expect(bob).not_to be_in_zone("3")
  #
  # You can create such a matcher like so:
  #
  #     RSpec::Matchers.define :be_in_zone do |zone|
  #       match do |player|
  #         player.in_zone?(zone)
  #       end
  #     end
  #
  # This will generate a <tt>be_in_zone</tt> method that returns a matcher
  # with logical default messages for failures. You can override the failure
  # messages and the generated description as follows:
  #
  #     RSpec::Matchers.define :be_in_zone do |zone|
  #       match do |player|
  #         player.in_zone?(zone)
  #       end
  #
  #       failure_message do |player|
  #         # generate and return the appropriate string.
  #       end
  #
  #       failure_message_when_negated do |player|
  #         # generate and return the appropriate string.
  #       end
  #
  #       description do
  #         # generate and return the appropriate string.
  #       end
  #     end
  #
  # Each of the message-generation methods has access to the block arguments
  # passed to the <tt>create</tt> method (in this case, <tt>zone</tt>). The
  # failure message methods (<tt>failure_message</tt> and
  # <tt>failure_message_when_negated</tt>) are passed the actual value (the
  # receiver of <tt>expect(..)</tt> or <tt>expect(..).not_to</tt>).
  #
  # ### Custom Matcher from scratch
  #
  # You could also write a custom matcher from scratch, as follows:
  #
  #     class BeInZone
  #       def initialize(expected)
  #         @expected = expected
  #       end
  #
  #       def matches?(target)
  #         @target = target
  #         @target.current_zone.eql?(Zone.new(@expected))
  #       end
  #
  #       def failure_message
  #         "expected #{@target.inspect} to be in Zone #{@expected}"
  #       end
  #
  #       def failure_message_when_negated
  #         "expected #{@target.inspect} not to be in Zone #{@expected}"
  #       end
  #     end
  #
  # ... and a method like this:
  #
  #     def be_in_zone(expected)
  #       BeInZone.new(expected)
  #     end
  #
  # And then expose the method to your specs. This is normally done
  # by including the method and the class in a module, which is then
  # included in your spec:
  #
  #     module CustomGameMatchers
  #       class BeInZone
  #         # ...
  #       end
  #
  #       def be_in_zone(expected)
  #         # ...
  #       end
  #     end
  #
  #     describe "Player behaviour" do
  #       include CustomGameMatchers
  #       # ...
  #     end
  #
  # or you can include in globally in a spec_helper.rb file <tt>require</tt>d
  # from your spec file(s):
  #
  #     RSpec::configure do |config|
  #       config.include(CustomGameMatchers)
  #     end
  #
  # ### Making custom matchers composable
  #
  # RSpec's built-in matchers are designed to be composed, in expressions like:
  #
  #     expect(["barn", 2.45]).to contain_exactly(
  #       a_value_within(0.1).of(2.5),
  #       a_string_starting_with("bar")
  #     )
  #
  # Custom matchers can easily participate in composed matcher expressions like these.
  # Include {RSpec::Matchers::Composable} in your custom matcher to make it support
  # being composed (matchers defined using the DSL have this included automatically).
  # Within your matcher's `matches?` method (or the `match` block, if using the DSL),
  # use `values_match?(expected, actual)` rather than `expected == actual`.
  # Under the covers, `values_match?` is able to match arbitrary
  # nested data structures containing a mix of both matchers and non-matcher objects.
  # It uses `===` and `==` to perform the matching, considering the values to
  # match if either returns `true`. The `Composable` mixin also provides some helper
  # methods for surfacing the matcher descriptions within your matcher's description
  # or failure messages.
  #
  # RSpec's built-in matchers each have a number of aliases that rephrase the matcher
  # from a verb phrase (such as `be_within`) to a noun phrase (such as `a_value_within`),
  # which reads better when the matcher is passed as an argument in a composed matcher
  # expressions, and also uses the noun-phrase wording in the matcher's `description`,
  # for readable failure messages. You can alias your custom matchers in similar fashion
  # using {RSpec::Matchers.alias_matcher}.
  module Matchers
    # @method expect
    # Supports `expect(actual).to matcher` syntax by wrapping `actual` in an
    # `ExpectationTarget`.
    # @example
    #   expect(actual).to eq(expected)
    #   expect(actual).not_to eq(expected)
    # @return [ExpectationTarget]
    # @see ExpectationTarget#to
    # @see ExpectationTarget#not_to

    # Defines a matcher alias. The returned matcher's `description` will be overriden
    # to reflect the phrasing of the new name, which will be used in failure messages
    # when passed as an argument to another matcher in a composed matcher expression.
    #
    # @param new_name [Symbol] the new name for the matcher
    # @param old_name [Symbol] the original name for the matcher
    # @yield [String] optional block that, when given is used to define the overriden
    #   description. The yielded arg is the original description. If no block is
    #   provided, a default description override is used based on the old and
    #   new names.
    #
    # @example
    #
    #   RSpec::Matchers.alias_matcher :a_list_that_sums_to, :sum_to
    #   sum_to(3).description # => "sum to 3"
    #   a_list_that_sums_to(3).description # => "a list that sums to 3"
    #
    # @example
    #
    #   RSpec::Matchers.alias_matcher :a_list_sorted_by, :be_sorted_by do |description|
    #     description.sub("be sorted by", "a list sorted by")
    #   end
    #
    #   be_sorted_by(:age).description # => "be sorted by age"
    #   a_list_sorted_by(:age).description # => "a list sorted by age"
    #
    # @!macro [attach] alias_matcher
    #   @!parse
    #     alias $1 $2
    def self.alias_matcher(new_name, old_name, &description_override)
      description_override ||= lambda do |old_desc|
        old_desc.gsub(Pretty.split_words(old_name), Pretty.split_words(new_name))
      end

      define_method(new_name) do |*args, &block|
        matcher = __send__(old_name, *args, &block)
        AliasedMatcher.new(matcher, description_override)
      end
    end

    # Passes if actual is truthy (anything but false or nil)
    def be_truthy
      BuiltIn::BeTruthy.new
    end
    alias_matcher :a_truthy_value, :be_truthy

    # Passes if actual is falsey (false or nil)
    def be_falsey
      BuiltIn::BeFalsey.new
    end
    alias_matcher :be_falsy,       :be_falsey
    alias_matcher :a_falsey_value, :be_falsey
    alias_matcher :a_falsy_value,  :be_falsey

    # Passes if actual is nil
    def be_nil
      BuiltIn::BeNil.new
    end
    alias_matcher :a_nil_value, :be_nil

    # @example
    #   expect(actual).to     be_truthy
    #   expect(actual).to     be_falsey
    #   expect(actual).to     be_nil
    #   expect(actual).to     be_[arbitrary_predicate](*args)
    #   expect(actual).not_to be_nil
    #   expect(actual).not_to be_[arbitrary_predicate](*args)
    #
    # Given true, false, or nil, will pass if actual value is true, false or
    # nil (respectively). Given no args means the caller should satisfy an if
    # condition (to be or not to be).
    #
    # Predicates are any Ruby method that ends in a "?" and returns true or
    # false.  Given be_ followed by arbitrary_predicate (without the "?"),
    # RSpec will match convert that into a query against the target object.
    #
    # The arbitrary_predicate feature will handle any predicate prefixed with
    # "be_an_" (e.g. be_an_instance_of), "be_a_" (e.g. be_a_kind_of) or "be_"
    # (e.g. be_empty), letting you choose the prefix that best suits the
    # predicate.
    def be(*args)
      args.empty? ? Matchers::BuiltIn::Be.new : equal(*args)
    end
    alias_matcher :a_value, :be

    # passes if target.kind_of?(klass)
    def be_a(klass)
      be_a_kind_of(klass)
    end
    alias_method :be_an, :be_a

    # Passes if actual.instance_of?(expected)
    #
    # @example
    #
    #   expect(5).to     be_an_instance_of(Fixnum)
    #   expect(5).not_to be_an_instance_of(Numeric)
    #   expect(5).not_to be_an_instance_of(Float)
    def be_an_instance_of(expected)
      BuiltIn::BeAnInstanceOf.new(expected)
    end
    alias_method :be_instance_of, :be_an_instance_of
    alias_matcher :an_instance_of, :be_an_instance_of

    # Passes if actual.kind_of?(expected)
    #
    # @example
    #
    #   expect(5).to     be_a_kind_of(Fixnum)
    #   expect(5).to     be_a_kind_of(Numeric)
    #   expect(5).not_to be_a_kind_of(Float)
    def be_a_kind_of(expected)
      BuiltIn::BeAKindOf.new(expected)
    end
    alias_method :be_kind_of, :be_a_kind_of
    alias_matcher :a_kind_of,  :be_a_kind_of

    # Passes if actual.between?(min, max). Works with any Comparable object,
    # including String, Symbol, Time, or Numeric (Fixnum, Bignum, Integer,
    # Float, Complex, and Rational).
    #
    # By default, `be_between` is inclusive (i.e. passes when given either the max or min value),
    # but you can make it `exclusive` by chaining that off the matcher.
    #
    # @example
    #
    #   expect(5).to      be_between(1, 10)
    #   expect(11).not_to be_between(1, 10)
    #   expect(10).not_to be_between(1, 10).exclusive
    def be_between(min, max)
      BuiltIn::BeBetween.new(min, max)
    end
    alias_matcher :a_value_between, :be_between

    # Passes if actual == expected +/- delta
    #
    # @example
    #
    #   expect(result).to     be_within(0.5).of(3.0)
    #   expect(result).not_to be_within(0.5).of(3.0)
    def be_within(delta)
      BuiltIn::BeWithin.new(delta)
    end
    alias_matcher :a_value_within, :be_within
    alias_matcher :within,         :be_within

    # Applied to a proc, specifies that its execution will cause some value to
    # change.
    #
    # @param [Object] receiver
    # @param [Symbol] message the message to send the receiver
    #
    # You can either pass <tt>receiver</tt> and <tt>message</tt>, or a block,
    # but not both.
    #
    # When passing a block, it must use the `{ ... }` format, not
    # do/end, as `{ ... }` binds to the `change` method, whereas do/end
    # would errantly bind to the `expect(..).to` or `expect(...).not_to` method.
    #
    # You can chain any of the following off of the end to specify details
    # about the change:
    #
    # * `by`
    # * `by_at_least`
    # * `by_at_most`
    # * `from`
    # * `to`
    #
    # @example
    #
    #   expect {
    #     team.add_player(player)
    #   }.to change(roster, :count)
    #
    #   expect {
    #     team.add_player(player)
    #   }.to change(roster, :count).by(1)
    #
    #   expect {
    #     team.add_player(player)
    #   }.to change(roster, :count).by_at_least(1)
    #
    #   expect {
    #     team.add_player(player)
    #   }.to change(roster, :count).by_at_most(1)
    #
    #   string = "string"
    #   expect {
    #     string.reverse!
    #   }.to change { string }.from("string").to("gnirts")
    #
    #   string = "string"
    #   expect {
    #     string
    #   }.not_to change { string }.from("string")
    #
    #   expect {
    #     person.happy_birthday
    #   }.to change(person, :birthday).from(32).to(33)
    #
    #   expect {
    #     employee.develop_great_new_social_networking_app
    #   }.to change(employee, :title).from("Mail Clerk").to("CEO")
    #
    #   expect {
    #     doctor.leave_office
    #   }.to change(doctor, :sign).from(/is in/).to(/is out/)
    #
    #   user = User.new(:type => "admin")
    #   expect {
    #     user.symbolize_type
    #   }.to change(user, :type).from(String).to(Symbol)
    #
    # == Notes
    #
    # Evaluates `receiver.message` or `block` before and after it
    # evaluates the block passed to `expect`.
    #
    # `expect( ... ).not_to change` supports the form that specifies `from`
    # (which specifies what you expect the starting, unchanged value to be)
    # but does not support forms with subsequent calls to `by`, `by_at_least`,
    # `by_at_most` or `to`.
    def change(receiver=nil, message=nil, &block)
      BuiltIn::Change.new(receiver, message, &block)
    end
    alias_matcher :a_block_changing,  :change
    alias_matcher :changing,          :change

    # Passes if actual contains all of the expected regardless of order.
    # This works for collections. Pass in multiple args and it will only
    # pass if all args are found in collection.
    #
    # @note This is also available using the `=~` operator with `should`,
    #       but `=~` is not supported with `expect`.
    #
    # @note This matcher only supports positive expectations.
    #       `expect(...).not_to contain_exactly(other_array)` is not supported.
    #
    # @example
    #
    #   expect([1, 2, 3]).to contain_exactly(1, 2, 3)
    #   expect([1, 2, 3]).to contain_exactly(1, 3, 2)
    #
    # @see #match_array
    def contain_exactly(*items)
      BuiltIn::ContainExactly.new(items)
    end
    alias_matcher :a_collection_containing_exactly, :contain_exactly
    alias_matcher :containing_exactly,              :contain_exactly

    # Passes if actual covers expected. This works for
    # Ranges. You can also pass in multiple args
    # and it will only pass if all args are found in Range.
    #
    # @example
    #   expect(1..10).to     cover(5)
    #   expect(1..10).to     cover(4, 6)
    #   expect(1..10).to     cover(4, 6, 11) # fails
    #   expect(1..10).not_to cover(11)
    #   expect(1..10).not_to cover(5)        # fails
    #
    # ### Warning:: Ruby >= 1.9 only
    def cover(*values)
      BuiltIn::Cover.new(*values)
    end
    alias_matcher :a_range_covering, :cover
    alias_matcher :covering,         :cover

    # Matches if the actual value ends with the expected value(s). In the case
    # of a string, matches against the last `expected.length` characters of the
    # actual string. In the case of an array, matches against the last
    # `expected.length` elements of the actual array.
    #
    # @example
    #
    #   expect("this string").to   end_with "string"
    #   expect([0, 1, 2, 3, 4]).to end_with 4
    #   expect([0, 2, 3, 4, 4]).to end_with 3, 4
    def end_with(*expected)
      BuiltIn::EndWith.new(*expected)
    end
    alias_matcher :a_collection_ending_with, :end_with
    alias_matcher :a_string_ending_with,     :end_with
    alias_matcher :ending_with,              :end_with

    # Passes if <tt>actual == expected</tt>.
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more
    # information about equality in Ruby.
    #
    # @example
    #
    #   expect(5).to     eq(5)
    #   expect(5).not_to eq(3)
    def eq(expected)
      BuiltIn::Eq.new(expected)
    end
    alias_matcher :an_object_eq_to, :eq
    alias_matcher :eq_to,           :eq

    # Passes if `actual.eql?(expected)`
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more
    # information about equality in Ruby.
    #
    # @example
    #
    #   expect(5).to     eql(5)
    #   expect(5).not_to eql(3)
    def eql(expected)
      BuiltIn::Eql.new(expected)
    end
    alias_matcher :an_object_eql_to, :eql
    alias_matcher :eql_to,           :eql

    # Passes if <tt>actual.equal?(expected)</tt> (object identity).
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more
    # information about equality in Ruby.
    #
    # @example
    #
    #   expect(5).to       equal(5)   # Fixnums are equal
    #   expect("5").not_to equal("5") # Strings that look the same are not the same object
    def equal(expected)
      BuiltIn::Equal.new(expected)
    end
    alias_matcher :an_object_equal_to, :equal
    alias_matcher :equal_to,           :equal

    # Passes if `actual.exist?` or `actual.exists?`
    #
    # @example
    #   expect(File).to exist("path/to/file")
    def exist(*args)
      BuiltIn::Exist.new(*args)
    end
    alias_matcher :an_object_existing, :exist
    alias_matcher :existing,           :exist

    # Passes if actual includes expected. This works for
    # collections and Strings. You can also pass in multiple args
    # and it will only pass if all args are found in collection.
    #
    # @example
    #
    #   expect([1,2,3]).to      include(3)
    #   expect([1,2,3]).to      include(2,3)
    #   expect([1,2,3]).to      include(2,3,4) # fails
    #   expect([1,2,3]).not_to  include(4)
    #   expect("spread").to     include("read")
    #   expect("spread").not_to include("red")
    def include(*expected)
      BuiltIn::Include.new(*expected)
    end
    alias_matcher :a_collection_including, :include
    alias_matcher :a_string_including,     :include
    alias_matcher :a_hash_including,       :include
    alias_matcher :including,              :include

    # Passes if actual all expected objects pass. This works for
    # any enumerable object.
    #
    # @example
    #
    #   expect([1, 3, 5]).to all be_odd
    #   expect([1, 3, 6]).to all be_odd # fails
    #
    # @note The negative form `not_to all` is not supported. Instead
    #   use `not_to include` or pass a negative form of a matcher
    #   as the argument (e.g. `all exclude(:foo)`).
    #
    # @note You can also use this with compound matchers as well.
    #
    # @example
    #   expect([1, 3, 5]).to all( be_odd.and be_an(Integer) )
    def all(expected)
      BuiltIn::All.new(expected)
    end

    # Given a `Regexp` or `String`, passes if `actual.match(pattern)`
    # Given an arbitrary nested data structure (e.g. arrays and hashes),
    # matches if `expected === actual` || `actual == expected` for each
    # pair of elements.
    #
    # @example
    #
    #   expect(email).to match(/^([^\s]+)((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    #   expect(email).to match("@example.com")
    #
    # @example
    #
    #   hash = {
    #     :a => {
    #       :b => ["foo", 5],
    #       :c => { :d => 2.05 }
    #     }
    #   }
    #
    #   expect(hash).to match(
    #     :a => {
    #       :b => a_collection_containing_exactly(
    #         a_string_starting_with("f"),
    #         an_instance_of(Fixnum)
    #       ),
    #       :c => { :d => (a_value < 3) }
    #     }
    #   )
    #
    # @note The `match_regex` alias is deprecated and is not recommended for use.
    #       It was added in 2.12.1 to facilitate its use from within custom
    #       matchers (due to how the custom matcher DSL was evaluated in 2.x,
    #       `match` could not be used there), but is no longer needed in 3.x.
    def match(expected)
      BuiltIn::Match.new(expected)
    end
    alias_matcher :match_regex,        :match
    alias_matcher :an_object_matching, :match
    alias_matcher :a_string_matching,  :match
    alias_matcher :matching,           :match

    # An alternate form of `contain_exactly` that accepts
    # the expected contents as a single array arg rather
    # that splatted out as individual items.
    #
    # @example
    #
    #   expect(results).to contain_exactly(1, 2)
    #   # is identical to:
    #   expect(results).to match_array([1, 2])
    #
    # @see #contain_exactly
    def match_array(items)
      contain_exactly(*items)
    end

    # With no arg, passes if the block outputs `to_stdout` or `to_stderr`.
    # With a string, passes if the blocks outputs that specific string `to_stdout` or `to_stderr`.
    # With a regexp or matcher, passes if the blocks outputs a string `to_stdout` or `to_stderr` that matches.
    #
    # @example
    #
    #   expect { print 'foo' }.to output.to_stdout
    #   expect { print 'foo' }.to output('foo').to_stdout
    #   expect { print 'foo' }.to output(/foo/).to_stdout
    #
    #   expect { do_something }.to_not output.to_stdout
    #
    #   expect { warn('foo') }.to output.to_stderr
    #   expect { warn('foo') }.to output('foo').to_stderr
    #   expect { warn('foo') }.to output(/foo/).to_stderr
    #
    #   expect { do_something }.to_not output.to_stderr
    #
    # @note This matcher works by temporarily replacing `$stdout` or `$stderr`,
    #   so it's not able to intercept stream output that explicitly uses `STDOUT`/`STDERR`
    #   or that uses a reference to `$stdout`/`$stderr` that was stored before the
    #   matcher is used.
    def output(expected=nil)
      BuiltIn::Output.new(expected)
    end
    alias_matcher :a_block_outputting, :output

    # With no args, matches if any error is raised.
    # With a named error, matches only if that specific error is raised.
    # With a named error and messsage specified as a String, matches only if both match.
    # With a named error and messsage specified as a Regexp, matches only if both match.
    # Pass an optional block to perform extra verifications on the exception matched
    #
    # @example
    #
    #   expect { do_something_risky }.to raise_error
    #   expect { do_something_risky }.to raise_error(PoorRiskDecisionError)
    #   expect { do_something_risky }.to raise_error(PoorRiskDecisionError) { |error| expect(error.data).to eq 42 }
    #   expect { do_something_risky }.to raise_error(PoorRiskDecisionError, "that was too risky")
    #   expect { do_something_risky }.to raise_error(PoorRiskDecisionError, /oo ri/)
    #
    #   expect { do_something_risky }.not_to raise_error
    def raise_error(error=Exception, message=nil, &block)
      BuiltIn::RaiseError.new(error, message, &block)
    end
    alias_method :raise_exception,  :raise_error

    alias_matcher :a_block_raising,  :raise_error do |desc|
      desc.sub("raise", "a block raising")
    end

    alias_matcher :raising,        :raise_error do |desc|
      desc.sub("raise", "raising")
    end

    # Matches if the target object responds to all of the names
    # provided. Names can be Strings or Symbols.
    #
    # @example
    #
    #   expect("string").to respond_to(:length)
    #
    def respond_to(*names)
      BuiltIn::RespondTo.new(*names)
    end
    alias_matcher :an_object_responding_to, :respond_to
    alias_matcher :responding_to,           :respond_to

    # Passes if the submitted block returns true. Yields target to the
    # block.
    #
    # Generally speaking, this should be thought of as a last resort when
    # you can't find any other way to specify the behaviour you wish to
    # specify.
    #
    # If you do find yourself in such a situation, you could always write
    # a custom matcher, which would likely make your specs more expressive.
    #
    # @example
    #
    #   expect(5).to satisfy { |n| n > 3 }
    def satisfy(&block)
      BuiltIn::Satisfy.new(&block)
    end
    alias_matcher :an_object_satisfying, :satisfy
    alias_matcher :satisfying,           :satisfy

    # Matches if the actual value starts with the expected value(s). In the
    # case of a string, matches against the first `expected.length` characters
    # of the actual string. In the case of an array, matches against the first
    # `expected.length` elements of the actual array.
    #
    # @example
    #
    #   expect("this string").to   start_with "this s"
    #   expect([0, 1, 2, 3, 4]).to start_with 0
    #   expect([0, 2, 3, 4, 4]).to start_with 0, 1
    def start_with(*expected)
      BuiltIn::StartWith.new(*expected)
    end
    alias_matcher :a_collection_starting_with, :start_with
    alias_matcher :a_string_starting_with,     :start_with
    alias_matcher :starting_with,              :start_with

    # Given no argument, matches if a proc throws any Symbol.
    #
    # Given a Symbol, matches if the given proc throws the specified Symbol.
    #
    # Given a Symbol and an arg, matches if the given proc throws the
    # specified Symbol with the specified arg.
    #
    # @example
    #
    #   expect { do_something_risky }.to throw_symbol
    #   expect { do_something_risky }.to throw_symbol(:that_was_risky)
    #   expect { do_something_risky }.to throw_symbol(:that_was_risky, 'culprit')
    #
    #   expect { do_something_risky }.not_to throw_symbol
    #   expect { do_something_risky }.not_to throw_symbol(:that_was_risky)
    #   expect { do_something_risky }.not_to throw_symbol(:that_was_risky, 'culprit')
    def throw_symbol(expected_symbol=nil, expected_arg=nil)
      BuiltIn::ThrowSymbol.new(expected_symbol, expected_arg)
    end

    alias_matcher :a_block_throwing, :throw_symbol do |desc|
      desc.sub("throw", "a block throwing")
    end

    alias_matcher :throwing,        :throw_symbol do |desc|
      desc.sub("throw", "throwing")
    end

    # Passes if the method called in the expect block yields, regardless
    # of whether or not arguments are yielded.
    #
    # @example
    #
    #   expect { |b| 5.tap(&b) }.to yield_control
    #   expect { |b| "a".to_sym(&b) }.not_to yield_control
    #
    # @note Your expect block must accept a parameter and pass it on to
    #   the method-under-test as a block.
    # @note This matcher is not designed for use with methods that yield
    #   multiple times.
    def yield_control
      BuiltIn::YieldControl.new
    end
    alias_matcher :a_block_yielding_control,  :yield_control
    alias_matcher :yielding_control,          :yield_control

    # Passes if the method called in the expect block yields with
    # no arguments. Fails if it does not yield, or yields with arguments.
    #
    # @example
    #
    #   expect { |b| User.transaction(&b) }.to yield_with_no_args
    #   expect { |b| 5.tap(&b) }.not_to yield_with_no_args # because it yields with `5`
    #   expect { |b| "a".to_sym(&b) }.not_to yield_with_no_args # because it does not yield
    #
    # @note Your expect block must accept a parameter and pass it on to
    #   the method-under-test as a block.
    # @note This matcher is not designed for use with methods that yield
    #   multiple times.
    def yield_with_no_args
      BuiltIn::YieldWithNoArgs.new
    end
    alias_matcher :a_block_yielding_with_no_args,  :yield_with_no_args
    alias_matcher :yielding_with_no_args,          :yield_with_no_args

    # Given no arguments, matches if the method called in the expect
    # block yields with arguments (regardless of what they are or how
    # many there are).
    #
    # Given arguments, matches if the method called in the expect block
    # yields with arguments that match the given arguments.
    #
    # Argument matching is done using `===` (the case match operator)
    # and `==`. If the expected and actual arguments match with either
    # operator, the matcher will pass.
    #
    # @example
    #
    #   expect { |b| 5.tap(&b) }.to yield_with_args # because #tap yields an arg
    #   expect { |b| 5.tap(&b) }.to yield_with_args(5) # because 5 == 5
    #   expect { |b| 5.tap(&b) }.to yield_with_args(Fixnum) # because Fixnum === 5
    #   expect { |b| File.open("f.txt", &b) }.to yield_with_args(/txt/) # because /txt/ === "f.txt"
    #
    #   expect { |b| User.transaction(&b) }.not_to yield_with_args # because it yields no args
    #   expect { |b| 5.tap(&b) }.not_to yield_with_args(1, 2, 3)
    #
    # @note Your expect block must accept a parameter and pass it on to
    #   the method-under-test as a block.
    # @note This matcher is not designed for use with methods that yield
    #   multiple times.
    def yield_with_args(*args)
      BuiltIn::YieldWithArgs.new(*args)
    end
    alias_matcher :a_block_yielding_with_args,  :yield_with_args
    alias_matcher :yielding_with_args,          :yield_with_args

    # Designed for use with methods that repeatedly yield (such as
    # iterators). Passes if the method called in the expect block yields
    # multiple times with arguments matching those given.
    #
    # Argument matching is done using `===` (the case match operator)
    # and `==`. If the expected and actual arguments match with either
    # operator, the matcher will pass.
    #
    # @example
    #
    #   expect { |b| [1, 2, 3].each(&b) }.to yield_successive_args(1, 2, 3)
    #   expect { |b| { :a => 1, :b => 2 }.each(&b) }.to yield_successive_args([:a, 1], [:b, 2])
    #   expect { |b| [1, 2, 3].each(&b) }.not_to yield_successive_args(1, 2)
    #
    # @note Your expect block must accept a parameter and pass it on to
    #   the method-under-test as a block.
    def yield_successive_args(*args)
      BuiltIn::YieldSuccessiveArgs.new(*args)
    end
    alias_matcher :a_block_yielding_successive_args,  :yield_successive_args
    alias_matcher :yielding_successive_args,          :yield_successive_args

    # Delegates to {RSpec::Expectations.configuration}.
    # This is here because rspec-core's `expect_with` option
    # looks for a `configuration` method on the mixin
    # (`RSpec::Matchers`) to yield to a block.
    # @return [RSpec::Expectations::Configuration] the configuration object
    def self.configuration
      Expectations.configuration
    end

  private

    BE_PREDICATE_REGEX = /^(be_(?:an?_)?)(.*)/
    HAS_REGEX = /^(?:have_)(.*)/

    def method_missing(method, *args, &block)
      case method.to_s
      when BE_PREDICATE_REGEX
        BuiltIn::BePredicate.new(method, *args, &block)
      when HAS_REGEX
        BuiltIn::Has.new(method, *args, &block)
      else
        super
      end
    end

    # @api private
    def self.is_a_matcher?(obj)
      return true  if ::RSpec::Matchers::BuiltIn::BaseMatcher === obj
      return false if obj.respond_to?(:i_respond_to_everything_so_im_not_really_a_matcher)
      return false unless obj.respond_to?(:matches?)

      obj.respond_to?(:failure_message) ||
      obj.respond_to?(:failure_message_for_should) # support legacy matchers
    end

    # @api private
    def self.is_a_describable_matcher?(obj)
      is_a_matcher?(obj) && obj.respond_to?(:description)
    end
  end
end
