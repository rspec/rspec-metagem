Feature: around hook

  Scenario: define around(:each) block in example group
    Given a file named "around_each_in_example_group_spec.rb" with:
      """
      require 'rspec/expectations'

      class Thing
        def self.cache
          @cache ||= []
        end

        def initialize
          self.class.cache << self
        end
      end

      describe Thing do
        around(:each) do |example|
          Thing.new
          example.run
          Thing.cache.clear
        end

        it "has 1 Thing (1)" do
          Thing.cache.length.should == 1
        end

        it "has 1 Thing (2)" do
          Thing.cache.length.should == 1
        end
      end
      """
    When I run "rspec around_each_in_example_group_spec.rb"
    Then the stderr should not match "NoMethodError"
    Then the stdout should match "2 examples, 0 failures"
