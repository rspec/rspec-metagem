Feature: raise_error matcher

  The raise_error matcher is used to specify that a block of code
  raises an error.  The most basic form passes if any error is thrown:

    expect { raise StandardError }.to raise_error

  You'll often want to specify that a particular error is thrown:

    expect { raise ArgumentError }.to raise_error(ArgumentError)

  If you care about the message given to the error, you can specify 
  that using both strings and regular expressions:

    expect { raise StandardError, "my message" }.to raise_error(StandardError, "my message")
    expect { raise StandardError, "my message" }.to raise_error(StandardError, /mess/)

  If you want to assert on the error itself you can pass a block to the matcher:

    expect { raise StandardError }.to raise_error{|error| error.should be_a_kind_of(StandardError)}

  You can also assert that the block of code does not raise an error:

    expect { 1 + 1 }.to_not raise_error # fails if any error is raised
    expect { 1 + 1 }.to_not raise_error(ArgumentError) # passes if anything other than an ArgumentError is raised
    expect { 1 + 1 }.to_not raise_error(ArgumentError, "my message") # passes if an ArgumentError is raise with a different message
    expect { 1 + 1 }.to_not raise_error(ArgumentError, /mess/) # passes if an ArgumentError is raised that doesn't match the regexp


  Scenario: expect error
    Given a file named "expect_error_spec.rb" with:
      """
      describe Object, "#non_existent_message" do
        it "should raise" do
          expect{Object.non_existent_message}.to raise_error(NameError)
        end
      end

      #deliberate failure
      describe Object, "#public_instance_methods" do
        it "should raise" do
          expect{Object.public_instance_methods}.to raise_error(NameError)
        end
      end
      """
    When I run "rspec ./expect_error_spec.rb"
    Then the output should contain "2 examples, 1 failure"
    Then the output should contain "expected NameError but nothing was raised"

  Scenario: expect no error
    Given a file named "expect_no_error_spec.rb" with:
      """
      describe Object, "#public_instance_methods" do
        it "should not raise" do
          expect{Object.public_instance_methods}.to_not raise_error(NameError)
        end
      end

      #deliberate failure
      describe Object, "#non_existent_message" do
        it "should not raise" do
          expect{Object.non_existent_message}.to_not raise_error(NameError)
        end
      end
      """
    When I run "rspec ./expect_no_error_spec.rb"
    Then the output should contain "2 examples, 1 failure"
    Then the output should contain "undefined method `non_existent_message'"

  Scenario: expect error with a message
    Given a file named "expect_error_with_message.rb" with:
      """
        describe "matching error message with string" do
          it "should match the error message" do
            expect{ raise StandardError, 'my message'}.to raise_error(StandardError, 'my message')
          end
          #deliberate failure
          it "should match the error message" do
            expect{ raise StandardError, 'another message'}.to raise_error(StandardError, 'my message')
          end
        end
      """
    When I run "rspec ./expect_error_with_message.rb"
    Then the output should contain all of these:
      | 2 examples, 1 failure                    |
      | expected StandardError with "my message" |

  Scenario: expect error with regular expression
    Given a file named "expect_error_with_regex.rb" with:
      """
      describe "matching error message with regex" do
        it "should match the error message" do
          expect{raise StandardError, "my message"}.to raise_error(StandardError, /mess/)
        end

        # deliberate failure
        it "should match the error message" do
          expect{raise StandardError, "my message"}.to raise_error(StandardError, /pass/)
        end
      end
      """
    When I run "rspec ./expect_error_with_regex.rb"
    Then the output should contain all of these:
      | 2 examples, 1 failure                               |
      | expected StandardError with message matching /pass/ |

  Scenario: expect no error with message
    Given a file named "expect_no_error_with_message.rb" with:
      """
        describe "matching no error with message" do
          it "should not match errors with a different message" do
            expect{raise StandardError, 'my message'}.to_not raise_error(StandardError, "another message")
          end

          #deliberate failure
          it "should not match errors with a different message" do
            expect{raise StandardError, "my message"}.to_not raise_error(StandardError, 'my message')
          end
        end
      """
    When I run "rspec ./expect_no_error_with_message.rb"
    Then the output should contain all of these:
      | 2 examples, 1 failure                       |
      | expected no StandardError with "my message" |

  Scenario: expect error with block
    Given a file named "expect_error_with_block_spec.rb" with:
      """
      describe "accessing expected error" do
        let(:expected_error){ StandardError.new}

        it "should pass the error to the block" do
          expect{raise expected_error}.to raise_error{|block_error|
            block_error.should eq(expected_error)
          }
        end

        # deliberate failure to assert block called
        it "should pass the error to the block" do
          expect{raise expected_error}.to raise_error{|block_error|
            block_error.should_not eq(expected_error)
          }
        end

      end
      """
      When I run "rspec ./expect_error_with_block_spec.rb"
      Then the output should contain all of these:
        | 2 examples, 1 failure |
        | expected #<StandardError: StandardError> not to equal #<StandardError: StandardError> |

