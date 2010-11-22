Feature: be matchers

  There are several related "be" matchers:

    * obj.should be_true # passes if obj is truthy (not nil or false)
    * obj.should be_false # passes if obj is falsey (nil or false)
    * obj.should be_nil # passes if obj is nil
    * obj.should be # passes if obj is not nil
    * obj.should be < expected # passes if obj < expected
    * obj.should be > expected # passes if obj > expected
    * obj.should be <= expected # passes if obj <= expected
    * obj.should be >= expected # passes if obj >= expected

  Scenario: be_true matcher
    Given a file named "be_true_spec.rb" with:
      """
      describe "be_true matcher" do
        specify { true.should be_true }
        specify { 7.should be_true }
        specify { "foo".should be_true }
        specify { nil.should_not be_true }
        specify { false.should_not be_true }

        # deliberate failures
        specify { true.should_not be_true }
        specify { 7.should_not be_true }
        specify { "foo".should_not be_true }
        specify { nil.should be_true }
        specify { false.should be_true }
      end
      """
    When I run "rspec be_true_spec.rb"
    Then the output should contain all of these:
      | 10 examples, 5 failures       |
      | expected true not to be true  |
      | expected 7 not to be true     |
      | expected "foo" not to be true |
      | expected nil to be true       |
      | expected false to be true     |

  Scenario: be_false matcher
    Given a file named "be_false_spec.rb" with:
      """
      describe "be_false matcher" do
        specify { nil.should be_false }
        specify { false.should be_false }
        specify { true.should_not be_false }
        specify { 7.should_not be_false }
        specify { "foo".should_not be_false }

        # deliberate failures
        specify { nil.should_not be_false }
        specify { false.should_not be_false }
        specify { true.should be_false }
        specify { 7.should be_false }
        specify { "foo".should be_false }
      end
      """
    When I run "rspec be_false_spec.rb"
    Then the output should contain all of these:
      | 10 examples, 5 failures        |
      | expected nil not to be false   |
      | expected false not to be false |
      | expected true to be false      |
      | expected 7 to be false         |
      | expected "foo" to be false     |

  Scenario: be_nil matcher
    Given a file named "be_nil_spec.rb" with:
      """
      describe "be_nil matcher" do
        specify { nil.should be_nil }
        specify { false.should_not be_nil }
        specify { true.should_not be_nil }
        specify { 7.should_not be_nil }
        specify { "foo".should_not be_nil }

        # deliberate failures
        specify { nil.should_not be_nil }
        specify { false.should be_nil }
        specify { true.should be_nil }
        specify { 7.should be_nil }
        specify { "foo".should be_nil }
      end
      """
    When I run "rspec be_nil_spec.rb"
    Then the output should contain all of these:
      | 10 examples, 5 failures   |
      | expected not nil, got nil |
      | expected nil, got false   |
      | expected nil, got true    |
      | expected nil, got 7       |
      | expected nil, got "foo"   |

  Scenario: be matcher
    Given a file named "be_spec.rb" with:
      """
      describe "be_matcher" do
        specify { true.should be }
        specify { 7.should be }
        specify { "foo".should be }
        specify { nil.should_not be }
        specify { false.should_not be }

        # deliberate failures
        specify { true.should_not be }
        specify { 7.should_not be }
        specify { "foo".should_not be }
        specify { nil.should be }
        specify { false.should be }
      end
      """
    When I run "rspec be_spec.rb"
    Then the output should contain all of these:
      | 10 examples, 5 failures             |
      | expected true to evaluate to false  |
      | expected 7 to evaluate to false     |
      | expected "foo" to evaluate to false |
      | expected nil to evaluate to true    |
      | expected false to evaluate to true  |

  Scenario: be operator matchers
    Given a file named "be_operators_spec.rb" with:
      """
      describe 17 do
        it { should be < 20 }
        it { should be > 15 }
        it { should be <= 17 }
        it { should be >= 17 }
        it { should_not be < 15 }
        it { should_not be > 20 }
        it { should_not be <= 16 }
        it { should_not be >= 18 }

        # deliberate failures
        it { should be < 15 }
        it { should be > 20 }
        it { should be <= 16 }
        it { should be >= 18 }
      end
      """
    When I run "rspec be_operators_spec.rb"
    Then the output should contain all of these:
      | 12 examples, 4 failures           |
      | expected < 15, got 17             |
      | expected > 20, got 17             |
      | expected <= 16, got 17            |
      | expected >= 18, got 17            |

