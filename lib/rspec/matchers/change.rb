module RSpec
  module Matchers
    
    #Based on patch from Wilson Bilkovich
    class Change #:nodoc:
      def initialize(receiver=nil, message=nil, &block)
        @message = message
        @value_proc = block || lambda {receiver.__send__(message)}
        @to = @from = @minimum = @maximum = @amount = nil
        @given_from = @given_to = false
      end
      
      def matches?(event_proc)
        raise_block_syntax_error if block_given?
        
        @before = evaluate_value_proc
        event_proc.call
        @after = evaluate_value_proc
      
        (!change_expected? || changed?) && matches_before? && matches_after? && matches_amount? && matches_min? && matches_max?
      end

      def raise_block_syntax_error
        raise MatcherError.new(<<-MESSAGE
block passed to should or should_not change must use {} instead of do/end
MESSAGE
        )
      end
      
      def evaluate_value_proc
        @value_proc.call
      end
      
      def failure_message_for_should
        if @given_from && @before != @from
          "#{message} should have initially been #{@from.inspect}, but was #{@before.inspect}"
        elsif @given_to && @to != @after
          "#{message} should have been changed to #{@to.inspect}, but is now #{@after.inspect}"
        elsif @amount
          "#{message} should have been changed by #{@amount.inspect}, but was changed by #{actual_delta.inspect}"
        elsif @minimum
          "#{message} should have been changed by at least #{@minimum.inspect}, but was changed by #{actual_delta.inspect}"
        elsif @maximum
          "#{message} should have been changed by at most #{@maximum.inspect}, but was changed by #{actual_delta.inspect}"
        else
          "#{message} should have changed, but is still #{@before.inspect}"
        end
      end
      
      def actual_delta
        @after - @before
      end
      
      def failure_message_for_should_not
        "#{message} should not have changed, but did change from #{@before.inspect} to #{@after.inspect}"
      end
      
      def by(amount)
        @amount = amount
        self
      end
      
      def by_at_least(minimum)
        @minimum = minimum
        self
      end
      
      def by_at_most(maximum)
        @maximum = maximum
        self
      end      
      
      def to(to)
        @given_to = true
        @to = to
        self
      end
      
      def from (from)
        @given_from = true
        @from = from
        self
      end
      
      def description
        "change ##{message}"
      end

    private
      
      def message
        @message || "result"
      end

      def change_expected?
        @amount != 0
      end

      def changed?
        @before != @after
      end

      def matches_before?
        @given_from ? @from == @before : true
      end

      def matches_after?
        @given_to ? @to == @after : true
      end

      def matches_amount?
        @amount ? (@before + @amount == @after) : true
      end

      def matches_min?
        @minimum ? (@after - @before >= @minimum) : true
      end

      def matches_max?
        @maximum ? (@after - @before <= @maximum) : true
      end
      
    end
    
    # :call-seq:
    #   should change(receiver, message)
    #   should change(receiver, message).by(value)
    #   should change(receiver, message).from(old).to(new)
    #   should_not change(receiver, message)
    #
    #   should change {...}
    #   should change {...}.by(value)
    #   should change {...}.from(old).to(new)
    #   should_not change {...}
    #
    # Applied to a proc, specifies that its execution will cause some value to
    # change.
    #
    # You can either pass <tt>receiver</tt> and <tt>message</tt>, or a block,
    # but not both.
    #
    # When passing a block, it must use the <tt>{ ... }</tt> format, not
    # do/end, as <tt>{ ... }</tt> binds to the +change+ method, whereas do/end
    # would errantly bind to the +should+ or +should_not+ method.
    #
    # == Examples
    #
    #   lambda {
    #     team.add_player(player) 
    #   }.should change(roster, :count)
    #
    #   lambda {
    #     team.add_player(player) 
    #   }.should change(roster, :count).by(1)
    #
    #   lambda {
    #     team.add_player(player) 
    #   }.should change(roster, :count).by_at_least(1)
    #
    #   lambda {
    #     team.add_player(player)
    #   }.should change(roster, :count).by_at_most(1)    
    #
    #   string = "string"
    #   lambda {
    #     string.reverse!
    #   }.should change { string }.from("string").to("gnirts")
    #
    #   lambda {
    #     person.happy_birthday
    #   }.should change(person, :birthday).from(32).to(33)
    #       
    #   lambda {
    #     employee.develop_great_new_social_networking_app
    #   }.should change(employee, :title).from("Mail Clerk").to("CEO")
    #
    # == Notes
    #
    # Evaluates <tt>receiver.message</tt> or <tt>block</tt> before and after it
    # evaluates the proc object (generated by the lambdas in the examples
    # above).
    #
    # <tt>should_not change</tt> only supports the form with no subsequent
    # calls to <tt>by</tt>, <tt>by_at_least</tt>, <tt>by_at_most</tt>,
    # <tt>to</tt> or <tt>from</tt>.
    def change(receiver=nil, message=nil, &block)
      Matchers::Change.new(receiver, message, &block)
    end
  end
end
