module Rspec
  module Core
    module ExampleGroupSubject
      
      def self.included(kls)
        kls.extend   ClassMethods
        kls.__send__ :alias_method, :__should_for_example_group__,     :should
        kls.__send__ :alias_method, :__should_not_for_example_group__, :should_not
      end
      
      def subject
        @subject ||= instance_eval(&self.class.subject)
      end
      
      # When +should+ is called with no explicit receiver, the call is
      # delegated to the object returned by +subject+. Combined with
      # an implicit subject (see +subject+), this supports very concise
      # expressions.
      #
      # == Examples
      #
      #   describe Person do
      #     it { should be_eligible_to_vote }
      #   end
      def should(matcher=nil, message=nil)
        self == subject ? self.__should_for_example_group__(matcher) : subject.should(matcher,message)
      end

      # Just like +should+, +should_not+ delegates to the subject (implicit or
      # explicit) of the example group.
      #
      # == Examples
      #
      #   describe Person do
      #     it { should_not be_eligible_to_vote }
      #   end
      def should_not(matcher=nil, message=nil)
        self == subject ? self.__should_not_for_example_group__(matcher) : subject.should_not(matcher,message)
      end
      
      module ClassMethods
        # Defines an explicit subject for an example group which can then be the
        # implicit receiver (through delegation) of calls to +should+.
        #
        # == Examples
        #
        #   describe CheckingAccount, "with $50" do
        #     subject { CheckingAccount.new(:amount => 50, :currency => :USD) }
        #     it { should have_a_balance_of(50, :USD) }
        #     it { should_not be_overdrawn }
        #   end
        #
        # See +ExampleMethods#should+ for more information about this approach.
        def subject(&block)
          block.nil? ?
          explicit_subject || implicit_subject : @explicit_subject_block = block
        end
      
        attr_reader :explicit_subject_block # :nodoc:

      private

        def explicit_subject
          group = self
          while group.respond_to?(:explicit_subject_block)
            return group.explicit_subject_block if group.explicit_subject_block
            group = group.superclass
          end
        end

        def implicit_subject
          described = describes || description
          Class === described ? lambda { described.new } : lambda { described }
        end
      end
    end
  end
end
