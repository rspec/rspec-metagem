Feature: read command line configuration options from files

  RSpec reads command line configuration options from files in three different
  locations:

    * Local: `./.rspec-local` (i.e. in the project's root directory, can be
      gitignored)

    * Project:  `./.rspec` (i.e. in the project's root directory, usually
      checked into the project)

    * Global: `~/.rspec` (i.e. in the user's home directory)

  Configuration options are loaded from `~/.rspec`, `.rspec`, `.rspec-local`,
  command line switches, and the `SPEC_OPTS` environment variable (listed in
  lowest to highest precedence; for example, an option in `~/.rspec` can be
  overridden by an option in `.rspec-local`).

  Scenario: Color set in `.rspec`
    Given a file named ".rspec" with:
      """
      --force-color
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.describe "color_enabled?" do
        context "when set with RSpec.configure" do
          it "is true" do
            expect(RSpec.configuration).to be_color_enabled
          end
        end
      end
      """
    When I run `rspec ./spec/example_spec.rb`
    Then the examples should all pass

  Scenario: Custom options file
    Given a file named "my.options" with:
      """
      --format documentation
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.describe "formatter set in custom options file" do
        it "sets formatter" do
          expect(RSpec.configuration.formatters.first).
            to be_a(RSpec::Core::Formatters::DocumentationFormatter)
        end
      end
      """
    When I run `rspec spec/example_spec.rb --options my.options`
    Then the examples should all pass

  Scenario: RSpec ignores `./.rspec` when custom options file is used
    Given a file named "my.options" with:
      """
      --format documentation
      """
    And a file named ".rspec" with:
      """
      --no-color
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.describe "custom options file" do
        it "causes .rspec to be ignored" do
          expect(RSpec.configuration.color_mode).to eq(:automatic)
        end
      end
      """
    When I run `rspec spec/example_spec.rb --options my.options`
    Then the examples should all pass

  Scenario: Using ERB in `.rspec`
    Given a file named ".rspec" with:
      """
      --format <%= true ? 'documentation' : 'progress' %>
      """
    And a file named "spec/example_spec.rb" with:
      """ruby
      RSpec.describe "formatter" do
        it "is set to documentation" do
          expect(RSpec.configuration.formatters.first).
            to be_an(RSpec::Core::Formatters::DocumentationFormatter)
        end
      end
      """
    When I run `rspec ./spec/example_spec.rb`
    Then the examples should all pass
