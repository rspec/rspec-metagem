Feature: for groups matching

  Define block evaluated in the context of any example group matching filters given.

  Scenario: define method for groups matching metadata
    Given a file named "for_groups_matching_spec.rb" with:
      """
      RSpec.configure do |c|
        c.for_groups_matching :type => :special do
          def method_defined_in_config
            "it works"
          end
        end
      end

      describe "something", :type => :special do
        it "access methods defined in configuration" do
          method_defined_in_config.should eq("it works")
        end
      end
      """
    When I run "rspec for_groups_matching_spec.rb"
    Then the examples should all pass

  Scenario: define method using let for groups matching metadata
    Given a file named "for_groups_matching_spec.rb" with:
      """
      RSpec.configure do |c|
        c.for_groups_matching :type => :special do
          let(:method_defined_by_let_in_config) { "it works" }
        end
      end

      describe "something", :type => :special do
        it "access methods defined using let in configuration" do
          method_defined_by_let_in_config.should eq("it works")
        end
      end
      """
    When I run "rspec for_groups_matching_spec.rb"
    Then the examples should all pass

  Scenario: define subject for groups matching metadata
    Given a file named "for_groups_matching_spec.rb" with:
      """
      RSpec.configure do |c|
        c.for_groups_matching :type => :special do
          subject { :subject_defined_in_configuration }
        end
      end

      describe "something", :type => :special do
        it "uses the subject defined in configuration" do
          subject.should be(:subject_defined_in_configuration)
        end
      end
      """
    When I run "rspec for_groups_matching_spec.rb"
    Then the examples should all pass
