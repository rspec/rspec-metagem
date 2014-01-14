Feature: output to stream matchers

   The `output` matcher provides a way to assert that the block-under-test
   has emitted content to either `to_stdout` or `to_stderr`.

  With no argument the matcher asserts that there has been output, when you
  pass a string then it asserts the output is equal (`==`) to that string and
  if you pass a regular expression then it asserts the output matches it. With
  a regex or a matcher, it passes whenever the block-under-test outputs a
  string that matches the given string.

    * `output.to_stdout` matches if the block-under-test outputs to
      $stdout.

    * `output.to_stderr` matchets if the block-under-test outputs to
      $stderr.

    Note: This matchers won't be able to intercept output to stream when the
    explicit form `STDOUT.puts 'foo'` is used or in case the reference to the
    stream is stored before the matcher is used.

  Scenario: output_to_stdout matcher
    Given a file named "output_to_stdout_spec.rb" with:
      """ruby

      describe "output.to_stdout matcher" do
        specify { expect { print('foo') }.to output.to_stdout }
        specify { expect { print('foo') }.to output('foo').to_stdout }
        specify { expect { print('foo') }.to output(/foo/).to_stdout }
        specify { expect { }.to_not output.to_stdout }
        specify { expect { print('foo') }.to_not output('bar').to_stdout }
        specify { expect { print('foo') }.to_not output(/bar/).to_stdout }

        # deliberate failures
        specify { expect { }.to output.to_stdout }
        specify { expect { }.to output('foo').to_stdout }
        specify { expect { print('foo') }.to_not output.to_stdout }
        specify { expect { print('foo') }.to output('bar').to_stdout }
        specify { expect { print('foo') }.to output(/bar/).to_stdout }
      end
      """
    When I run `rspec output_to_stdout_spec.rb`
    Then the output should contain all of these:
      | 11 examples, 5 failures                                      |
      | expected block to output to stdout, but did not              |
      | expected block to not output to stdout, but did              |
      | expected block to output "bar" to stdout, but output "foo"   |
      | expected block to output "foo" to stdout, but output nothing |
      | expected block to output /bar/ to stdout, but output "foo"   |

  Scenario: output_to_stderr matcher
    Given a file named "output_to_stderr.rb" with:
      """ruby

      describe "output_to_stderr matcher" do
        specify { expect { warn('foo') }.to output.to_stderr }
        specify { expect { warn('foo') }.to output("foo\n").to_stderr }
        specify { expect { warn('foo') }.to output(/foo/).to_stderr }
        specify { expect { }.to_not output.to_stderr }
        specify { expect { warn('foo') }.to_not output('bar').to_stderr }
        specify { expect { warn('foo') }.to_not output(/bar/).to_stderr }

        # deliberate failures
        specify { expect { }.to output.to_stderr }
        specify { expect { }.to output('foo').to_stderr }
        specify { expect { warn('foo') }.to_not output.to_stderr }
        specify { expect { warn('foo') }.to output('bar').to_stderr }
        specify { expect { warn('foo') }.to output(/bar/).to_stderr }
      end
      """
    When I run `rspec output_to_stderr.rb`
    Then the output should contain all of these:
      | 11 examples, 5 failures                                      |
      | expected block to output to stderr, but did not              |
      | expected block to not output to stderr, but did              |
      | expected block to output "bar" to stderr, but output "foo\n" |
      | expected block to output "foo" to stderr, but output nothing |
      | expected block to output /bar/ to stderr, but output "foo\n" |
