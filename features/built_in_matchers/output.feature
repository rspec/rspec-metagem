Feature: output matcher

  The `output` matcher provides a way to assert that the
  has emitted content to either `$stdout` or `$stderr`.

  With no arg, passes if the block outputs `to_stdout` or `to_stderr`.
  With a string, passes if the blocks outputs that specific string
  `to_stdout` or `to_stderr`. With a regexp or matcher, passes if the
  blocks outputs a string `to_stdout` or `to_stderr` that matches.

  Note: This matcher works by temporarily replacing `$stdout` or `$stderr`,
  so it's not able to intercept stream output that explicitly uses `STDOUT`/`STDERR`
  or that uses a reference to `$stdout`/`$stderr` that was stored before the
  matcher is used.

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
