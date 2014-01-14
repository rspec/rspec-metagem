Feature: output to stream matchers

  There are two related matchers that allow you to specify whether a block
  outputs to a stream. With no args, the matcher passes whenever the
  block-under-test outputs. With a string argument, it passes whenever
  block-under-test outputs a string that `==` the given string. With a regex,
  it passes whenever the block-under-test outputs a string that matches the
  given string.

    * `output_to_stdout` matches if the block-under-test outputs to
      $stdout.

    * `output_to_stderr` matchets if the block-under-test outputs to
      $stderr.

    Note: This matchers won't be able to intercept output to stream when the
    explicit form `STDOUT.puts 'foo'` is used or in case the reference to the
    stream is stored before the matcher is used.

  Scenario: output_to_stdout matcher
    Given a file named "output_to_stdout_spec.rb" with:
      """ruby

      describe "output_to_stdout matcher" do
        specify { expect { print('foo') }.to output_to_stdout }
        specify { expect { print('foo') }.to output_to_stdout('foo') }
        specify { expect { print('foo') }.to output_to_stdout(/foo/) }
        specify { expect { }.to_not output_to_stdout }
        specify { expect { print('foo') }.to_not output_to_stdout('bar') }
        specify { expect { print('foo') }.to_not output_to_stdout(/bar/) }

        # deliberate failures
        specify { expect { }.to output_to_stdout }
        specify { expect { }.to output_to_stdout('foo') }
        specify { expect { print('foo') }.to_not output_to_stdout }
        specify { expect { print('foo') }.to output_to_stdout('bar') }
        specify { expect { print('foo') }.to output_to_stdout(/bar/) }
      end
      """
    When I run `rspec output_to_stdout_spec.rb`
    Then the output should contain all of these:
      | 11 examples, 5 failures                                                      |
      | expected block to output to stdout, but did not                              |
      | expected block to not output to stdout, but did                              |
      | expected block to output "bar" to stdout, but output "foo"                   |
      | expected block to output "foo" to stdout, but output nothing                 |
      | expected block to output a string matching /bar/ to stdout, but output "foo" |

  Scenario: output_to_stderr matcher
    Given a file named "output_to_stderr.rb" with:
      """ruby

      describe "output_to_stderr matcher" do
        specify { expect { warn('foo') }.to output_to_stderr }
        specify { expect { warn('foo') }.to output_to_stderr("foo\n") }
        specify { expect { warn('foo') }.to output_to_stderr(/foo/) }
        specify { expect { }.to_not output_to_stderr }
        specify { expect { warn('foo') }.to_not output_to_stderr('bar') }
        specify { expect { warn('foo') }.to_not output_to_stderr(/bar/) }

        # deliberate failures
        specify { expect { }.to output_to_stderr }
        specify { expect { }.to output_to_stderr('foo') }
        specify { expect { warn('foo') }.to_not output_to_stderr }
        specify { expect { warn('foo') }.to output_to_stderr('bar') }
        specify { expect { warn('foo') }.to output_to_stderr(/bar/) }
      end
      """
    When I run `rspec output_to_stderr.rb`
    Then the output should contain all of these:
      | 11 examples, 5 failures                                                        |
      | expected block to output to stderr, but did not                                |
      | expected block to not output to stderr, but did                                |
      | expected block to output "bar" to stderr, but output "foo\n"                   |
      | expected block to output "foo" to stderr, but output nothing                   |
      | expected block to output a string matching /bar/ to stderr, but output "foo\n" |
