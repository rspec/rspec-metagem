Feature: #for_groups_matching

  User can define block evaluated in the context of any example group matching filters given.

  Scenario: define new subject method and use let for models example groups
    Given a file named "for_groups_matching_spec.rb" with:
      """

      class User
      end

      class Factory
      end

      RSpec.configure do |c|
        c.for_groups_matching :type => :model do
          subject { Factory described_class.to_s.downcase }
          let(:valid_attributes) { Factory.attributes_for described_class.to_s }
        end
      end

      describe User, :type => :model do
        it "uses new defined methods for subject" do
          self.should_receive(:Factory).with('user')
          subject
        end

        it "allows to use defined let" do
          Factory.should_receive(:attributes_for).with('User')
          valid_attributes
        end
      end
      """
    When I run "rspec ./for_groups_matching_spec.rb"
    Then the examples should all pass


