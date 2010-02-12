Feature: block local expectations

  In order to set message expectations on ...
  As an RSpec user
  I want to configure the evaluation context

  Background:
    Given a file named "account.rb" with:
      """
      class Account
        def self.create
          yield new
        end

        def opening_balance(amount, currency)
        end
      end
      """

  Scenario: passing example
    Given a file named "account_passing_spec.rb" with:
      """
      require 'account'

      Rspec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "account DSL" do
        it "it succeeds when the block local receives the given call" do
          account = Account.new
          Account.should_receive(:create).and_yield do |account|
            account.should_receive(:opening_balance).with(100, :USD)
          end
          Account.create do
            opening_balance 100, :USD
          end
        end
      end
      """
    When I run "rspec account_passing_spec.rb"
    Then the stdout should match "1 example, 0 failures"
    
  Scenario: failing example
    
    Given a file named "account_failing_spec.rb" with:
      """
      require 'account'

      Rspec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "account DSL" do
        it "fails when the block local does not receive the expected call" do
          account = Account.new
          Account.should_receive(:create).and_yield do |account|
            account.should_receive(:opening_balance).with(100, :USD)
          end
          Account.create do
            # opening_balance is not called here
          end
        end
      end
      """

    When I run "rspec account_failing_spec.rb"
    Then the stdout should match "1 example, 1 failure"
