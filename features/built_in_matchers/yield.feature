Feature: yield matchers

  There are four related matchers that allow you to specify whether
  or not a method yields, how many times it yields, whether or not
  it yields with arguments, and what those arguments are.

    * `yield_control` matches if the method-under-test yields, regardless
      of whether or not arguments are yielded.
    * `yield_with_args` matches if the method-under-test yields with
      arguments. If arguments are provided to this matcher, it will
      only pass if the actual yielded arguments match the expected ones
      using `===` or `==`.
    * `yield_with_no_args` matches if the method-under-test yields with
      no arguments.
    * `yield_successive_args` is designed for iterators, and will match
      if the method-under-test yields the same number of times as arguments
      passed to this matcher, and all actual yielded arguments match the
      expected ones using `===` or `==`.

  Note: your expect block _must_ accept an argument that is then passed on to
  the method-under-test as a block. This acts as a "probe" that allows the matcher
  to detect whether or not your method yields, and, if so, how many times and what
  the yielded arguments are.

  Scenario: yield_control matcher
    Given a file named "yield_control_spec.rb" with:
      """
      describe "yield_control matcher" do
        specify { expect { |b| File.open("temp", "w", &b) }.to yield_control }
        specify { expect { |b| :foo.to_s(&b) }.not_to yield_control }

        # deliberate failures
        specify { expect { |b| :foo.to_s(&b) }.to yield_control }
        specify { expect { |b| File.open("temp", "w", &b) }.not_to yield_control }
      end
      """
    When I run `rspec yield_control_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                      |
      | expected given block to yield control       |
      | expected given block not to yield control   |

  Scenario: yield_with_args matcher
    Given a file named "yield_with_args_spec.rb" with:
      """
      describe "yield_with_args matcher" do
        specify { expect { |b| File.open("temp", "w", &b) }.to yield_with_args }
        specify { expect { |b| File.open("temp", "w", &b) }.to yield_with_args(File) }
        specify { expect { |b| "Foo 17".sub(/\d+/, &b) }.to yield_with_args("17") }
        specify { expect { |b| "Foo 17".sub(/\d+/, &b) }.to yield_with_args(/1\d/) }

        # deliberate failures
        specify { expect { |b| :foo.to_s(&b) }.to yield_with_args(3, 4) }
        specify { expect { |b| "Foo 17".sub(/\d+/, &b) }.to yield_with_args("18") }
        specify { expect { |b| File.open("temp", "w", &b) }.not_to yield_with_args(File) }
        specify { expect { |b| File.open("temp", "w", &b) }.not_to yield_with_args }
      end
      """
    When I run `rspec yield_with_args_spec.rb`
    Then the output should contain all of these:
      | 8 examples, 4 failures                                                                |
      | expected given block to yield with arguments, but did not yield                       |
      | expected given block to yield with arguments, but yielded with unexpected arguments   |
      | expected given block not to yield with arguments, but yielded with expected arguments |
      | expected given block not to yield with arguments, but did                             |

  Scenario: yield_with_no_args matcher
    Given a file named "yield_with_no_args_spec.rb" with:
      """
      def raw_yield
        yield
      end

      describe "yield_with_no_args matcher" do
        specify { expect { |b| raw_yield(&b) }.to yield_with_no_args }
        specify { expect { |b| :foo.to_s(&b) }.not_to yield_with_no_args }
        specify { expect { |b| File.open("temp", "w", &b) }.not_to yield_with_no_args }

        # deliberate failures
        specify { expect { |b| raw_yield(&b) }.not_to yield_with_no_args }
        specify { expect { |b| :foo.to_s(&b) }.to yield_with_no_args }
        specify { expect { |b| File.open("temp", "w", &b) }.to yield_with_no_args }
      end
      """
    When I run `rspec yield_with_no_args_spec.rb`
    Then the output should contain all of these:
      | 6 examples, 3 failures                                                                               |
      | expected given block not to yield with no arguments, but did                                         |
      | expected given block to yield with no arguments, but did not yield                                   |
      | expected given block to yield with no arguments, but yielded with arguments: [#<File:temp (closed)>] |

  Scenario: yield_successive_args matcher
    Given a file named "yield_successive_args_spec.rb" with:
      """
      def array
        [1, 2, 3]
      end

      def array_of_tuples
        [[:a, :b], [:c, :d]]
      end

      describe "yield_successive_args matcher" do
        specify { expect { |b| array.each(&b) }.to yield_successive_args(1, 2, 3) }
        specify { expect { |b| array_of_tuples.each(&b) }.to yield_successive_args([:a, :b], [:c, :d]) }
        specify { expect { |b| array.each(&b) }.to yield_successive_args(Fixnum, Fixnum, Fixnum) }
        specify { expect { |b| array.each(&b) }.not_to yield_successive_args(1, 2) }

        # deliberate failures
        specify { expect { |b| array.each(&b) }.not_to yield_successive_args(1, 2, 3) }
        specify { expect { |b| array_of_tuples.each(&b) }.not_to yield_successive_args([:a, :b], [:c, :d]) }
        specify { expect { |b| array.each(&b) }.not_to yield_successive_args(Fixnum, Fixnum, Fixnum) }
        specify { expect { |b| array.each(&b) }.to yield_successive_args(1, 2) }
      end
      """
    When I run `rspec yield_successive_args_spec.rb`
    Then the output should contain all of these:
      | 8 examples, 4 failures                                                                             |
      | expected given block not to yield successively with arguments, but yielded with expected arguments |
      | expected given block to yield successively with arguments, but yielded with unexpected arguments   |
