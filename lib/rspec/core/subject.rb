module RSpec
  module Core
    # @note `subject` was contributed by Joe Ferris to support the one-liner
    #   syntax embraced by shoulda matchers:
    #
    #       describe Widget do
    #         it { should validate_presence_of(:name) }
    #       end
    #
    #   While the examples below demonstrate how to use `subject`
    #   explicitly in examples, we recommend that you define a method with
    #   an intention revealing name instead.
    #
    # @example
    #
    #   # explicit declaration of subject
    #   describe Person do
    #     subject { Person.new(:birthdate => 19.years.ago) }
    #     it "should be eligible to vote" do
    #       subject.should be_eligible_to_vote
    #       # ^ ^ explicit reference to subject not recommended
    #     end
    #   end
    #
    #   # implicit subject => { Person.new }
    #   describe Person do
    #     it "should be eligible to vote" do
    #       subject.should be_eligible_to_vote
    #       # ^ ^ explicit reference to subject not recommended
    #     end
    #   end
    #
    #   # one-liner syntax - should is invoked on subject
    #   describe Person do
    #     it { should be_eligible_to_vote }
    #   end
    module Subject
      module ExampleMethods
        # When `should` is called with no explicit receiver, the call is
        # delegated to the object returned by `subject`. Combined with an
        # implicit subject this supports very concise expressions.
        #
        # @example
        #
        #   describe Person do
        #     it { should be_eligible_to_vote }
        #   end
        #
        # @see #subject
        def should(matcher=nil, message=nil)
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(subject, matcher, message)
        end

        # Just like `should`, `should_not` delegates to the subject (implicit or
        # explicit) of the example group.
        #
        # @example
        #
        #   describe Person do
        #     it { should_not be_eligible_to_vote }
        #   end
        #
        # @see #subject
        def should_not(matcher=nil, message=nil)
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(subject, matcher, message)
        end

        private

        def _attribute_chain(attribute)
          attribute.to_s.split('.')
        end

        def _nested_attribute(subject, attribute)
          _attribute_chain(attribute).inject(subject) do |inner_subject, attr|
            inner_subject.send(attr)
          end
        end
      end

      module ExampleGroupMethods
        # Creates a nested example group named by the submitted `attribute`,
        # and then generates an example using the submitted block.
        #
        # @example
        #
        #   # This ...
        #   describe Array do
        #     its(:size) { should eq(0) }
        #   end
        #
        #   # ... generates the same runtime structure as this:
        #   describe Array do
        #     describe "size" do
        #       it "should eq(0)" do
        #         subject.size.should eq(0)
        #       end
        #     end
        #   end
        #
        # The attribute can be a `Symbol` or a `String`. Given a `String`
        # with dots, the result is as though you concatenated that `String`
        # onto the subject in an expression.
        #
        # @example
        #
        #   describe Person do
        #     subject do
        #       Person.new.tap do |person|
        #         person.phone_numbers << "555-1212"
        #       end
        #     end
        #
        #     its("phone_numbers.first") { should eq("555-1212") }
        #   end
        #
        # When the subject is a `Hash`, you can refer to the Hash keys by
        # specifying a `Symbol` or `String` in an array.
        #
        # @example
        #
        #   describe "a configuration Hash" do
        #     subject do
        #       { :max_users => 3,
        #         'admin' => :all_permissions }
        #     end
        #
        #     its([:max_users]) { should eq(3) }
        #     its(['admin']) { should eq(:all_permissions) }
        #
        #     # You can still access to its regular methods this way:
        #     its(:keys) { should include(:max_users) }
        #     its(:count) { should eq(2) }
        #   end
        def its(attribute, &block)
          describe(attribute) do
            example do
              self.class.class_eval do
                define_method(:subject) do
                  if defined?(@_subject)
                    @_subject
                  else
                    @_subject = Array === attribute ? super()[*attribute] : _nested_attribute(super(), attribute)
                  end
                end
              end
              instance_eval(&block)
            end
          end
        end

        # Declares a `subject` for an example group which can then be the
        # implicit receiver (through delegation) of calls to `should`.
        #
        # Given a `name`, defines a method with that name which returns the
        # `subject`. This lets you declare the subject once and access it
        # implicitly in one-liners and explicitly using an intention revealing
        # name.
        #
        # @param [String,Symbol] name used to define an accessor with an
        #   intention revealing name
        # @param block defines the value to be returned by `subject` in examples
        #
        # @example
        #
        #   describe CheckingAccount, "with $50" do
        #     subject { CheckingAccount.new(Money.new(50, :USD)) }
        #     it { should have_a_balance_of(Money.new(50, :USD)) }
        #     it { should_not be_overdrawn }
        #   end
        #
        #   describe CheckingAccount, "with a non-zero starting balance" do
        #     subject(:account) { CheckingAccount.new(Money.new(50, :USD)) }
        #     it { should_not be_overdrawn }
        #     it "has a balance equal to the starting balance" do
        #       account.balance.should eq(Money.new(50, :USD))
        #     end
        #   end
        #
        # @see ExampleMethods#should
        def subject(name=nil, &block)
          let(:subject, &block)
          alias_method name, :subject if name
        end

        def self.extended(base)
          # This logic defines an implicit subject.
          base.subject do
            described = described_class || self.class.description
            Class === described ? described.new : described
          end
        end

        # Just like `subject`, except the block is invoked by an implicit `before`
        # hook. This serves a dual purpose of setting up state and providing a
        # memoized reference to that state.
        #
        # @example
        #
        #   class Thing
        #     def self.count
        #       @count ||= 0
        #     end
        #
        #     def self.count=(val)
        #       @count += val
        #     end
        #
        #     def self.reset_count
        #       @count = 0
        #     end
        #
        #     def initialize
        #       self.class.count += 1
        #     end
        #   end
        #
        #   describe Thing do
        #     after(:each) { Thing.reset_count }
        #
        #     context "using subject" do
        #       subject { Thing.new }
        #
        #       it "is not invoked implicitly" do
        #         Thing.count.should eq(0)
        #       end
        #
        #       it "can be invoked explicitly" do
        #         subject
        #         Thing.count.should eq(1)
        #       end
        #     end
        #
        #     context "using subject!" do
        #       subject!(:thing) { Thing.new }
        #
        #       it "is invoked implicitly" do
        #         Thing.count.should eq(1)
        #       end
        #
        #       it "returns memoized version on first invocation" do
        #         subject
        #         Thing.count.should eq(1)
        #       end
        #     end
        #   end
        def subject!(name=nil, &block)
          subject(name, &block)
          before { __send__(:subject) }
        end
      end
    end
  end
end

