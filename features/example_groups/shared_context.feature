Feature: shared context

  Use `shared_context` to define a block that will be evaluated in the context
  of example groups either explicitly, using `include_context`, or implicitly by
  matching metdata.
  
  Scenario: declare and use shared context with a string name
    Given a file named "shared_context_spec.rb" with:
      """
      shared_context "shared stuff", :a => :b do
        before { @some_var = :some_value }
        def shared_method
          "it works"
        end
        let(:shared_let) { {'arbitrary' => 'object'} }
        subject do
          'this is the subject'
        end
      end

      shared_examples_for "group including shared context" do
        it "has access to methods defined in shared context" do
          shared_method.should eq("it works")
        end

        it "has access to methods defined with let in shared context" do
          shared_let['arbitrary'].should eq('object')
        end

        it "runs the before hooks defined in the shared context" do
          @some_var.should be(:some_value)
        end

        it "accesses the subject defined in the shared context" do
          subject.should eq('this is the subject')
        end
      end

      describe "group that includes a shared context using 'include_context'" do
        include_context "shared stuff"
        it_behaves_like "group including shared context"
      end

      describe "group that includes a shared context using metadata", :a => :b do
        it_behaves_like "group including shared context"
      end
      """
    When I run `rspec shared_context_spec.rb`
    Then the output should contain "8 examples"
    And the examples should all pass

  Scenario: share a method
    Given a file named "shared_context_spec.rb" with:
      """
      shared_context :type => :special do
        def shared_method
          "it works"
        end
      end

      describe "something", :type => :special do
        it "access methods defined in configuration" do
          shared_method.should eq("it works")
        end
      end
      """
    When I run `rspec shared_context_spec.rb`
    Then the examples should all pass

  Scenario: share a `let` declaration
    Given a file named "shared_context_spec.rb" with:
      """
      shared_context :type => :special do
        let(:method_defined_by_let_in_config) { "it works" }
      end

      describe "something", :type => :special do
        it "access methods defined using let in configuration" do
          method_defined_by_let_in_config.should eq("it works")
        end
      end
      """
    When I run `rspec shared_context_spec.rb`
    Then the examples should all pass

  Scenario: share a subject
    Given a file named "shared_context_spec.rb" with:
      """
      shared_context :type => :special do
        subject { :subject_defined_in_configuration }
      end

      describe "something", :type => :special do
        it "uses the subject defined in configuration" do
          subject.should be(:subject_defined_in_configuration)
        end
      end
      """
    When I run `rspec shared_context_spec.rb`
    Then the examples should all pass

  @wip
  Scenario: Use symbols as metadata
    Given a file named "use_symbols_as_metadata_spec.rb" with:
      """
      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
      end

      shared_context :special do
        let(:help) { :available }
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
