require 'rspec/core/filter_manager'
require 'rspec/core/dsl'
require 'rspec/core/extensions'
require 'rspec/core/load_path'
require 'rspec/core/deprecation'
require 'rspec/core/backward_compatibility'
require 'rspec/core/reporter'

require 'rspec/core/metadata_hash_builder'
require 'rspec/core/hooks'
require 'rspec/core/subject'
require 'rspec/core/let'
require 'rspec/core/metadata'
require 'rspec/core/pending'

require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/command_line_configuration'
require 'rspec/core/option_parser'
require 'rspec/core/drb_options'
require 'rspec/core/configuration_options'
require 'rspec/core/command_line'
require 'rspec/core/drb_command_line'
require 'rspec/core/runner'
require 'rspec/core/example'
require 'rspec/core/shared_example_group'
require 'rspec/core/example_group'
require 'rspec/core/version'
require 'rspec/core/errors'

module RSpec
  autoload :Matchers,      'rspec/matchers'
  autoload :SharedContext, 'rspec/core/shared_context'

  # @api private
  # Used internally to determine what to do when a SIGINT is received
  def self.wants_to_quit
    world.wants_to_quit
  end

  # @api private
  # Used internally to determine what to do when a SIGINT is received
  def self.wants_to_quit=(maybe)
    world.wants_to_quit=(maybe)
  end

  # @api private
  # Internal container for global non-configuration data
  def self.world
    @world ||= RSpec::Core::World.new
  end

  # @api private
  # Used internally to ensure examples get reloaded between multiple runs in
  # the same process.
  def self.reset
    world.reset
    configuration.reset
  end

  # Returns the global [Configuration](Core/Configuration) object. While you
  # _can_ use this method to access the configuration, the more common
  # convention is to use [RSpec.configure](RSpec#configure-class_method).
  #
  # @example
  #     RSpec.configuration.drb_port = 1234
  # @see RSpec.configure
  # @see Core::Configuration
  def self.configuration
    @configuration ||= RSpec::Core::Configuration.new
  end

  # @yield [Configuration] global configuration
  #
  # @example
  #     RSpec.configure do |config|
  #       config.add_formatter 'documentation'
  #     end
  # @see Core::Configuration
  def self.configure
    yield configuration if block_given?
  end

  # @api private
  # Used internally to clear remaining groups when fail_fast is set
  def self.clear_remaining_example_groups
    world.example_groups.clear
  end

  # rspec-core provides the structure for writing executable examples of how
  # your code should behave.  It uses the words "describe" and "it" so we can
  # express concepts like a conversation:
  #
  #     "Describe an order."
  #     "It sums the prices of its line items."
  #
  # ## Basic structure
  #
  #     describe Order do
  #       it "sums the prices of its line items" do
  #         order = Order.new
  #         order.add_entry(LineItem.new(:item => Item.new(
  #           :price => Money.new(1.11, :USD)
  #         )
  #         order.add_entry(LineItem.new(:item => Item.new(
  #           :price => Money.new(2.22, :USD),
  #           :quantity => 2
  #         )
  #         order.total.should eq(Money.new(5.55, :USD))
  #       end
  #     end
  #
  # The `describe` method creates an [ExampleGroup](Core/ExampleGroup).  Within the
  # block passed to `describe` you can declare examples using the `it` method.
  #
  # Under the hood, an example group is a class in which the block passed to
  # `describe` is evaluated. The blocks passed to `it` are evaluated in the
  # context of an _instance_ of that class.
  #
  # ## Nested groups
  #
  # You can also declare nested nested groups using the `describe` or `context`
  # methods:
  #
  #     describe Order to
  #       context "with no items" do
  #         it "behaves one way" do
  #           # ...
  #         end
  #       end
  #
  #       context "with one item" do
  #         it "behaves another way" do
  #           # ...
  #         end
  #       end
  #     end
  #
  # ## Aliases
  #
  # You can declare example groups using either `describe` or `context`, though
  # only `describe` is available at the top level.
  #
  # You can declare examples within a group using any of `it`, `specify`, or
  # `example`.
  #
  # ## Shared examples
  #
  # Declare a shared example group using `shared_examples`, and then include it
  # in each group using `include_examples`.
  #
  #     shared_examples "collections" do |collection_class|
  #       it "is empty when first created" do
  #         collection_class.new.should be_empty
  #       end
  #     end
  #
  #     describe Array do
  #       include_examples "collections", Array
  #     end
  #
  # ## Metadata
  #
  # rspec-core stores a metadata hash with every example and group, which
  # contains like their descriptions, the locations at which they were
  # declared, etc, etc. This hash powers many of rspec-core's features,
  # including output formatters (which access descriptions and locations),
  # and filtering before and after hooks.
  #
  # Although you probably won't ever need this unless you are writing an
  # extension, you can access it from an example like this:
  #
  #     it "does something" do
  #       example.metadata[:description].should eq("does something")
  #     end
  #
  # ### `described_class`
  #
  # When a class is passed to `describe`, you can access it from an example
  # using the `described_class` method, which is a wrapper for
  # `example.metadata[:described_class]`.
  #
  #     describe Widget do
  #       example do
  #         described_class.should equal(Widget)
  #       end
  #     end
  #
  # This is useful in extensions or shared example groups in which the specific
  # class is unknown. Taking the shared examples example from above, we can
  # clean it up a bit using `described_class`:
  #
  #     shared_examples "collections" do
  #       it "is empty when first created" do
  #         described.new.should be_empty
  #       end
  #     end
  #
  #     describe Array do
  #       include_examples "collections"
  #     end
  #
  #     describe Hash do
  #       include_examples "collections"
  #     end
  #
  # ## The `rspec` command
  #
  # When you install the rspec-core gem, it installs the `rspec` executable,
  # which you'll use to run rspec. The `rspec` comes with many useful options.
  # Run `rspec --help` to see the complete list.
  module Core
  end
end

require 'rspec/core/backward_compatibility'
require 'rspec/monkey'
