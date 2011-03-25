Feature: for groups matching

  Use `for_groups_matching` to define a block that will be evaluated
  in the context of any example groups that have matching metadata.

  If you set the `treat_symbols_as_metadata_keys_with_true_values` config option
  to `true`, you can specify metadata using only symbols.

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
    When I run `rspec for_groups_matching_spec.rb`
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
    When I run `rspec for_groups_matching_spec.rb`
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
    When I run `rspec for_groups_matching_spec.rb`
    Then the examples should all pass

  Scenario: Use symbols as metadata
    Given a file named "use_symbols_as_metadata_spec.rb" with:
      """
      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
        c.for_groups_matching :special do
          let(:help) { :available }
        end
      end

      describe "something", :special do
        it "accesses helper methods defined using `let` in the configuration" do
          help.should be(:available)
        end
      end

      describe "something else" do
        it "cannot access helper methods defined using `let` in the configuration" do
          expect { help }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec use_symbols_as_metadata_spec.rb`
    Then the examples should all pass
