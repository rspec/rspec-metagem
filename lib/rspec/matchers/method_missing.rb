module RSpec
  module Matchers
    private

    # Ruby 1.9 has a weird bug where you can get infinite recursion and a SystemStackError
    # under the following conditions:
    #   * You have a module that defines a method that uses super
    #   * You include that module in a subclass
    #   * You include that module in the subclass's superclass _after_ it has already
    #     been included in the subclass.
    # See https://gist.github.com/845896 for a demonstration of this bug.
    #
    # This manifested itself in RSpec with the method_missing hook below, because
    # rspec-core includes RSpec::Matchers in RSpec::Core::ExampleGroup right before
    # running all the examples (but after all the examples have been defined), so that
    # users can configure RSpec to use a different expectation/assertion framework if
    # they wish.  If users included RSpec::Matchers in an example group, undefined method
    # calls would trigger this bug.
    #
    # Our work around is to use alias_method_chain rather than super.  It's not as
    # elegant, but it fixes the issue.
    def self.included(base)
      base.class_eval do
        alias_method :method_missing_without_rspec_matchers, :method_missing
        alias_method :method_missing, :method_missing_with_rspec_matchers
      end
    end

    def method_missing_with_rspec_matchers(method, *args, &block) # :nodoc:
      return Matchers::BePredicate.new(method, *args, &block) if method.to_s =~ /^be_/
      return Matchers::Has.new(method, *args, &block) if method.to_s =~ /^have_/
      method_missing_without_rspec_matchers(method, *args, &block)
    end
  end
end
