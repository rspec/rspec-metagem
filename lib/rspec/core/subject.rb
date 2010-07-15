module RSpec
  module Core
    module Subject

      def self.included(kls)
        kls.class_eval do
          extend ClassMethods
          alias_method :__should_for_example_group__,     :should
          alias_method :__should_not_for_example_group__, :should_not
        end
      end

      def subject
        using_attribute? ? attribute_of_subject : original_subject
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
          block ? @explicit_subject_block = block : explicit_subject || implicit_subject
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
          Class === described ? proc { described.new } : proc { described }
        end
      end

    private

      def original_subject
        @original_subject ||= instance_eval(&self.class.subject)
      end

      def attribute_of_subject
        if using_attribute?
          example.description.split('.').inject(original_subject) do |target, method|
            target.send(method)
          end
        end
      end

      def using_attribute?
        example.in_block? &&
        example.metadata[:attribute_of_subject]
      end

    end
  end
end
