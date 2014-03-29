Feature: --order option

  Use the `--order` option to tell RSpec how to order the files, groups, and
  examples. The available ordering schemes are `defined` and `rand`.

  `defined` is the default, which executes groups and examples in the
  order they are defined as the spec files are loaded.

  Use `rand` to randomize the order of groups and examples within the groups.
  Nested groups are always run from top-level to bottom-level in order to avoid
    executing `before(:context)` and `after(:context)` hooks more than once, but the order
    of groups at each level is randomized.

  With `rand` you can also specify a seed.

  Scenario: Example usage

    The `defined` option is only necessary when you have `--order rand` stored in a
    config file (e.g. `.rspec`) and you want to override it from the command line.

    <pre><code class="bash">--order defined
    --order rand
    --order rand:123
    --seed 123 # same as --order rand:123
    </code></pre>
