require 'fileutils'
require 'rspec/core/backtrace_formatter'
require 'rspec/core/ruby_project'
require 'rspec/core/formatters/deprecation_formatter'

module RSpec
  module Core
    # Stores runtime configuration information.
    #
    # Configuration options are loaded from `~/.rspec`, `.rspec`,
    # `.rspec-local`, command line switches, and the `SPEC_OPTS` environment
    # variable (listed in lowest to highest precedence; for example, an option
    # in `~/.rspec` can be overridden by an option in `.rspec-local`).
    #
    # @example Standard settings
    #     RSpec.configure do |c|
    #       c.drb          = true
    #       c.drb_port     = 1234
    #       c.default_path = 'behavior'
    #     end
    #
    # @example Hooks
    #     RSpec.configure do |c|
    #       c.before(:suite) { establish_connection }
    #       c.before(:each)  { log_in_as :authorized }
    #       c.around(:each)  { |ex| Database.transaction(&ex) }
    #     end
    #
    # @see RSpec.configure
    # @see Hooks
    class Configuration
      include RSpec::Core::Hooks

      class MustBeConfiguredBeforeExampleGroupsError < StandardError; end

      # @private
      def self.define_reader(name)
        define_method(name) do
          variable = instance_variable_defined?("@#{name}") ? instance_variable_get("@#{name}") : nil
          value_for(name, variable)
        end
      end

      # @private
      def self.define_aliases(name, alias_name)
        alias_method alias_name, name
        alias_method "#{alias_name}=", "#{name}="
        define_predicate_for alias_name
      end

      # @private
      def self.define_predicate_for(*names)
        names.each {|name| alias_method "#{name}?", name}
      end

      # @private
      #
      # Invoked by the `add_setting` instance method. Use that method on a
      # `Configuration` instance rather than this class method.
      def self.add_setting(name, opts={})
        raise "Use the instance add_setting method if you want to set a default" if opts.has_key?(:default)
        attr_writer name
        add_read_only_setting name

        Array(opts[:alias_with]).each do |alias_name|
          define_aliases(name, alias_name)
        end
      end

      # @private
      #
      # As `add_setting` but only add the reader
      def self.add_read_only_setting(name, opts={})
        raise "Use the instance add_setting method if you want to set a default" if opts.has_key?(:default)
        define_reader name
        define_predicate_for name
      end

      # @macro [attach] add_setting
      #   @attribute $1
      #
      # @macro [attach] define_reader
      #   @attribute $1

      # @macro add_setting
      # Path to use if no path is provided to the `rspec` command (default:
      # `"spec"`). Allows you to just type `rspec` instead of `rspec spec` to
      # run all the examples in the `spec` directory.
      add_setting :default_path

      # @macro add_setting
      # Run examples over DRb (default: `false`). RSpec doesn't supply the DRb
      # server, but you can use tools like spork.
      add_setting :drb

      # @macro add_setting
      # The drb_port (default: nil).
      add_setting :drb_port

      # @macro add_setting
      # Default: `$stderr`.
      add_setting :error_stream

      # Indicates if the DSL has been exposed off of modules and `main`.
      # Default: true
      def expose_dsl_globally?
        Core::DSL.exposed_globally?
      end

      # Use this to expose the core RSpec DSL via `Module` and the `main`
      # object. It will be set automatically but you can override it to
      # remove the DSL.
      # Default: true
      def expose_dsl_globally=(value)
        if value
          Core::DSL.expose_globally!
          Core::SharedExampleGroup::TopLevelDSL.expose_globally!
        else
          Core::DSL.remove_globally!
          Core::SharedExampleGroup::TopLevelDSL.remove_globally!
        end
      end

      # @macro add_setting
      # Default: `$stderr`.
      add_setting :deprecation_stream

      # @macro add_setting
      # Clean up and exit after the first failure (default: `false`).
      add_setting :fail_fast

      # @macro add_setting
      # Prints the formatter output of your suite without running any
      # examples or hooks.
      add_setting :dry_run

      # @macro add_setting
      # The exit code to return if there are any failures (default: 1).
      add_setting :failure_exit_code

      # @macro define_reader
      # Indicates files configured to be required
      define_reader :requires

      # @macro define_reader
      # Returns dirs that have been prepended to the load path by #lib=
      define_reader :libs

      # @macro add_setting
      # Default: `$stdout`.
      # Also known as `output` and `out`
      define_reader :output_stream
      def output_stream=(value)
        if @reporter && !value.equal?(@output_stream)
          warn "RSpec's reporter has already been initialized with " +
            "#{output_stream.inspect} as the output stream, so your change to "+
            "`output_stream` will be ignored. You should configure it earlier for " +
            "it to take effect. (Called from #{CallerFilter.first_non_rspec_line})"
        else
          @output_stream = value
        end
      end

      # @macro add_setting
      # Load files matching this pattern (default: `'**/*_spec.rb'`)
      add_setting :pattern, :alias_with => :filename_pattern

      def pattern= value
        if @spec_files_loaded
          RSpec.warning "Configuring `pattern` to #{value} has no effect since RSpec has already loaded the spec files."
        end
        @pattern = value
      end
      alias :filename_pattern= :pattern=

      # @macro add_setting
      # Report the times for the slowest examples (default: `false`).
      # Use this to specify the number of examples to include in the profile.
      add_setting :profile_examples

      # @macro add_setting
      # Run all examples if none match the configured filters (default: `false`).
      add_setting :run_all_when_everything_filtered

      # @macro add_setting
      # Color to use to indicate success.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :success_color

      # @macro add_setting
      # Color to use to print pending examples.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :pending_color

      # @macro add_setting
      # Color to use to indicate failure.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :failure_color

      # @macro add_setting
      # The default output color.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :default_color

      # @macro add_setting
      # Color used when a pending example is fixed.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :fixed_color

      # @macro add_setting
      # Color used to print details.
      # @param [Symbol] color one of the following: [:black, :white, :red, :green, :yellow, :blue, :magenta, :cyan]
      add_setting :detail_color

      # Deprecated. This config option was added in RSpec 2 to pave the way
      # for this being the default behavior in RSpec 3. Now this option is
      # a no-op.
      def treat_symbols_as_metadata_keys_with_true_values=(value)
        RSpec.deprecate("RSpec::Core::Configuration#treat_symbols_as_metadata_keys_with_true_values=",
                        :message => "RSpec::Core::Configuration#treat_symbols_as_metadata_keys_with_true_values=" +
                                    "is deprecated, it is now set to true as default and setting it to false has no effect.")
      end

      # @private
      add_setting :tty
      # @private
      add_setting :include_or_extend_modules
      # @private
      attr_writer :files_to_run
      # @private
      add_setting :expecting_with_rspec
      # @private
      attr_accessor :filter_manager
      # @private
      attr_reader :backtrace_formatter, :ordering_manager

      # Alias for rspec-2.x's backtrace_cleaner (now backtrace_formatter)
      #
      # TODO: consider deprecating and removing this rather than aliasing in rspec-3?
      alias backtrace_cleaner backtrace_formatter

      def initialize
        @expectation_frameworks = []
        @include_or_extend_modules = []
        @mock_framework = nil
        @files_or_directories_to_run = []
        @color = false
        @pattern = '**/*_spec.rb'
        @failure_exit_code = 1
        @spec_files_loaded = false

        @backtrace_formatter = BacktraceFormatter.new

        @default_path = 'spec'
        @deprecation_stream = $stderr
        @output_stream = $stdout
        @reporter = nil
        @filter_manager = FilterManager.new
        @ordering_manager = Ordering::ConfigurationManager.new
        @preferred_options = {}
        @failure_color = :red
        @success_color = :green
        @pending_color = :yellow
        @default_color = :white
        @fixed_color = :blue
        @detail_color = :cyan
        @profile_examples = false
        @requires = []
        @libs = []
      end

      # @private
      #
      # Used to set higher priority option values from the command line.
      def force(hash)
        ordering_manager.force(hash)
        @preferred_options.merge!(hash)
        self.warnings = value_for :warnings, nil
      end

      # @private
      def reset
        @spec_files_loaded = false
        @reporter = nil
        @formatter_loader = nil
      end

      # @overload add_setting(name)
      # @overload add_setting(name, opts)
      # @option opts [Symbol] :default
      #
      #   set a default value for the generated getter and predicate methods:
      #
      #       add_setting(:foo, :default => "default value")
      #
      # @option opts [Symbol] :alias_with
      #
      #   Use `:alias_with` to alias the setter, getter, and predicate to another
      #   name, or names:
      #
      #       add_setting(:foo, :alias_with => :bar)
      #       add_setting(:foo, :alias_with => [:bar, :baz])
      #
      # Adds a custom setting to the RSpec.configuration object.
      #
      #     RSpec.configuration.add_setting :foo
      #
      # Used internally and by extension frameworks like rspec-rails, so they
      # can add config settings that are domain specific. For example:
      #
      #     RSpec.configure do |c|
      #       c.add_setting :use_transactional_fixtures,
      #         :default => true,
      #         :alias_with => :use_transactional_examples
      #     end
      #
      # `add_setting` creates three methods on the configuration object, a
      # setter, a getter, and a predicate:
      #
      #     RSpec.configuration.foo=(value)
      #     RSpec.configuration.foo
      #     RSpec.configuration.foo? # returns true if foo returns anything but nil or false
      def add_setting(name, opts={})
        default = opts.delete(:default)
        (class << self; self; end).class_eval do
          add_setting(name, opts)
        end
        __send__("#{name}=", default) if default
      end

      # Returns the configured mock framework adapter module
      def mock_framework
        mock_with :rspec unless @mock_framework
        @mock_framework
      end

      # Delegates to mock_framework=(framework)
      def mock_framework=(framework)
        mock_with framework
      end

      # Regexps used to exclude lines from backtraces.
      #
      # Excludes lines from ruby (and jruby) source, installed gems, anything
      # in any "bin" directory, and any of the rspec libs (outside gem
      # installs) by default.
      #
      # You can modify the list via the getter, or replace it with the setter.
      #
      # To override this behaviour and display a full backtrace, use
      # `--backtrace`on the command line, in a `.rspec` file, or in the
      # `rspec_options` attribute of RSpec's rake task.
      def backtrace_exclusion_patterns
        @backtrace_formatter.exclusion_patterns
      end

      def backtrace_exclusion_patterns=(patterns)
        @backtrace_formatter.exclusion_patterns = patterns
      end

      # Regexps used to include lines in backtraces.
      #
      # Defaults to [Regexp.new Dir.getwd].
      #
      # Lines that match an exclusion _and_ an inclusion pattern
      # will be included.
      #
      # You can modify the list via the getter, or replace it with the setter.
      def backtrace_inclusion_patterns
        @backtrace_formatter.inclusion_patterns
      end

      def backtrace_inclusion_patterns=(patterns)
        @backtrace_formatter.inclusion_patterns = patterns
      end

      # @api private
      MOCKING_ADAPTERS = {
        :rspec    => :RSpec,
        :flexmock => :Flexmock,
        :rr       => :RR,
        :mocha    => :Mocha,
        :nothing  => :Null
      }

      # Sets the mock framework adapter module.
      #
      # `framework` can be a Symbol or a Module.
      #
      # Given any of `:rspec`, `:mocha`, `:flexmock`, or `:rr`, configures the
      # named framework.
      #
      # Given `:nothing`, configures no framework. Use this if you don't use
      # any mocking framework to save a little bit of overhead.
      #
      # Given a Module, includes that module in every example group. The module
      # should adhere to RSpec's mock framework adapter API:
      #
      #     setup_mocks_for_rspec
      #       - called before each example
      #
      #     verify_mocks_for_rspec
      #       - called after each example. Framework should raise an exception
      #         when expectations fail
      #
      #     teardown_mocks_for_rspec
      #       - called after verify_mocks_for_rspec (even if there are errors)
      #
      # If the module responds to `configuration` and `mock_with` receives a block,
      # it will yield the configuration object to the block e.g.
      #
      #     config.mock_with OtherMockFrameworkAdapter do |mod_config|
      #       mod_config.custom_setting = true
      #     end
      def mock_with(framework)
        framework_module = if framework.is_a?(Module)
           framework
        else
          const_name = MOCKING_ADAPTERS.fetch(framework) do
            raise ArgumentError,
              "Unknown mocking framework: #{framework.inspect}. " +
              "Pass a module or one of #{MOCKING_ADAPTERS.keys.inspect}"
          end

          require "rspec/core/mocking_adapters/#{const_name.to_s.downcase}"
          RSpec::Core::MockingAdapters.const_get(const_name)
        end

        new_name, old_name = [framework_module, @mock_framework].map do |mod|
          mod.respond_to?(:framework_name) ?  mod.framework_name : :unnamed
        end

        unless new_name == old_name
          assert_no_example_groups_defined(:mock_framework)
        end

        if block_given?
          raise "#{framework_module} must respond to `configuration` so that mock_with can yield it." unless framework_module.respond_to?(:configuration)
          yield framework_module.configuration
        end

        @mock_framework = framework_module
      end

      # Returns the configured expectation framework adapter module(s)
      def expectation_frameworks
        expect_with :rspec if @expectation_frameworks.empty?
        @expectation_frameworks
      end

      # Delegates to expect_with(framework)
      def expectation_framework=(framework)
        expect_with(framework)
      end

      # Sets the expectation framework module(s) to be included in each example
      # group.
      #
      # `frameworks` can be `:rspec`, `:stdlib`, a custom module, or any
      # combination thereof:
      #
      #     config.expect_with :rspec
      #     config.expect_with :stdlib
      #     config.expect_with :rspec, :stdlib
      #     config.expect_with OtherExpectationFramework
      #
      # RSpec will translate `:rspec` and `:stdlib` into the appropriate
      # modules.
      #
      # ## Configuration
      #
      # If the module responds to `configuration`, `expect_with` will
      # yield the `configuration` object if given a block:
      #
      #     config.expect_with OtherExpectationFramework do |custom_config|
      #       custom_config.custom_setting = true
      #     end
      def expect_with(*frameworks)
        modules = frameworks.map do |framework|
          case framework
          when Module
            framework
          when :rspec
            require 'rspec/expectations'
            self.expecting_with_rspec = true
            ::RSpec::Matchers
          when :stdlib
            require 'test/unit/assertions'
            ::Test::Unit::Assertions
          else
            raise ArgumentError, "#{framework.inspect} is not supported"
          end
        end

        if (modules - @expectation_frameworks).any?
          assert_no_example_groups_defined(:expect_with)
        end

        if block_given?
          raise "expect_with only accepts a block with a single argument. Call expect_with #{modules.length} times, once with each argument, instead." if modules.length > 1
          raise "#{modules.first} must respond to `configuration` so that expect_with can yield it." unless modules.first.respond_to?(:configuration)
          yield modules.first.configuration
        end

        @expectation_frameworks.push(*modules)
      end

      def full_backtrace?
        @backtrace_formatter.full_backtrace?
      end

      def full_backtrace=(true_or_false)
        @backtrace_formatter.full_backtrace = true_or_false
      end

      def color(output=output_stream)
        # rspec's built-in formatters all call this with the output argument,
        # but defaulting to output_stream for backward compatibility with
        # formatters in extension libs
        return false unless output_to_tty?(output)
        value_for(:color, @color)
      end

      def color=(bool)
        if bool
          if RSpec.windows_os? and not ENV['ANSICON']
            RSpec.warning "You must use ANSICON 1.31 or later (http://adoxa.3eeweb.com/ansicon/) to use colour on Windows"
            @color = false
          else
            @color = true
          end
        end
      end

      # TODO - deprecate color_enabled - probably not until the last 2.x
      # release before 3.0
      alias_method :color_enabled, :color
      alias_method :color_enabled=, :color=
      define_predicate_for :color_enabled, :color

      def libs=(libs)
        libs.map do |lib|
          @libs.unshift lib
          $LOAD_PATH.unshift lib
        end
      end

      # Run examples defined on `line_numbers` in all files to run.
      def line_numbers=(line_numbers)
        filter_run :line_numbers => line_numbers.map{|l| l.to_i}
      end

      def line_numbers
        filter.fetch(:line_numbers,[])
      end

      def full_description=(description)
        filter_run :full_description => Regexp.union(*Array(description).map {|d| Regexp.new(d) })
      end

      def full_description
        filter.fetch :full_description, nil
      end

      # @overload add_formatter(formatter)
      #
      # Adds a formatter to the formatters collection. `formatter` can be a
      # string representing any of the built-in formatters (see
      # `built_in_formatter`), or a custom formatter class.
      #
      # ### Note
      #
      # For internal purposes, `add_formatter` also accepts the name of a class
      # and paths to use for output streams, but you should consider that a
      # private api that may change at any time without notice.
      def add_formatter(formatter_to_use, *paths)
        paths << output_stream if paths.empty?
        formatter_loader.add formatter_to_use, *paths
      end
      alias_method :formatter=, :add_formatter

      # @api private
      def formatters
        formatter_loader.formatters
      end

      # @api private
      def formatter_loader
        @formatter_loader ||= Formatters::Loader.new(Reporter.new(self))
      end

      # @api private
      def reporter
        @reporter ||=
          begin
            formatter_loader.setup_default output_stream, deprecation_stream
            formatter_loader.reporter
          end
      end

      # @api private
      #
      # Defaults `profile_examples` to 10 examples when `@profile_examples` is `true`.
      #
      def profile_examples
        profile = value_for(:profile_examples, @profile_examples)
        if profile && !profile.is_a?(Integer)
          10
        else
          profile
        end
      end

      # @private
      def files_or_directories_to_run=(*files)
        files = files.flatten
        files << default_path if (command == 'rspec' || Runner.running_in_drb?) && default_path && files.empty?
        @files_or_directories_to_run = files
        @files_to_run = nil
      end

      def files_to_run
        @files_to_run ||= get_files_to_run(@files_or_directories_to_run)
      end

      # Creates a method that delegates to `example` including the submitted
      # `args`. Used internally to add variants of `example` like `pending`:
      #
      # @example
      #     alias_example_to :pending, :pending => true
      #
      #     # This lets you do this:
      #
      #     describe Thing do
      #       pending "does something" do
      #         thing = Thing.new
      #       end
      #     end
      #
      #     # ... which is the equivalent of
      #
      #     describe Thing do
      #       it "does something", :pending => true do
      #         thing = Thing.new
      #       end
      #     end
      def alias_example_to(new_name, *args)
        extra_options = Metadata.build_hash_from(args)
        RSpec::Core::ExampleGroup.alias_example_to(new_name, extra_options)
      end

      # Creates a method that defines an example group with the provided
      # metadata. Can be used to define example group/metadata shortcuts.
      #
      # @example
      #     alias_example_group_to :describe_model, :type => :model
      #     shared_context_for "model tests", :type => :model do
      #       # define common model test helper methods, `let` declarations, etc
      #     end
      #
      #     # This lets you do this:
      #
      #     RSpec.describe_model User do
      #     end
      #
      #     # ... which is the equivalent of
      #
      #     RSpec.describe User, :type => :model do
      #     end
      #
      # @note The defined aliased will also be added to the top level
      #       (e.g. `main` and from within modules) if
      #       `expose_dsl_globally` is set to true.
      # @see #alias_example_to
      # @see #expose_dsl_globally=
      def alias_example_group_to(new_name, *args)
        extra_options = Metadata.build_hash_from(args)
        RSpec::Core::ExampleGroup.alias_example_group_to(new_name, extra_options)
      end

      # Define an alias for it_should_behave_like that allows different
      # language (like "it_has_behavior" or "it_behaves_like") to be
      # employed when including shared examples.
      #
      # Example:
      #
      #     alias_it_behaves_like_to(:it_has_behavior, 'has behavior:')
      #
      # allows the user to include a shared example group like:
      #
      #     describe Entity do
      #       it_has_behavior 'sortability' do
      #         let(:sortable) { Entity.new }
      #       end
      #     end
      #
      # which is reported in the output as:
      #
      #     Entity
      #       has behavior: sortability
      #         # sortability examples here
      def alias_it_behaves_like_to(new_name, report_label = '')
        RSpec::Core::ExampleGroup.alias_it_behaves_like_to(new_name, report_label)
      end

      alias_method :alias_it_should_behave_like_to, :alias_it_behaves_like_to

      # Adds key/value pairs to the `inclusion_filter`. If `args`
      # includes any symbols that are not part of the hash, each symbol
      # is treated as a key in the hash with the value `true`.
      #
      # ### Note
      #
      # Filters set using this method can be overridden from the command line
      # or config files (e.g. `.rspec`).
      #
      # @example
      #     # given this declaration
      #     describe "something", :foo => 'bar' do
      #       # ...
      #     end
      #
      #     # any of the following will include that group
      #     config.filter_run_including :foo => 'bar'
      #     config.filter_run_including :foo => /^ba/
      #     config.filter_run_including :foo => lambda {|v| v == 'bar'}
      #     config.filter_run_including :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     # given a proc with an arity of 1, the lambda is passed the value related to the key, e.g.
      #     config.filter_run_including :foo => lambda {|v| v == 'bar'}
      #
      #     # given a proc with an arity of 2, the lambda is passed the value related to the key,
      #     # and the metadata itself e.g.
      #     config.filter_run_including :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     filter_run_including :foo # same as filter_run_including :foo => true
      def filter_run_including(*args)
        filter_manager.include_with_low_priority Metadata.build_hash_from(args)
      end

      alias_method :filter_run, :filter_run_including

      # Clears and reassigns the `inclusion_filter`. Set to `nil` if you don't
      # want any inclusion filter at all.
      #
      # ### Warning
      #
      # This overrides any inclusion filters/tags set on the command line or in
      # configuration files.
      def inclusion_filter=(filter)
        filter_manager.include! Metadata.build_hash_from([filter])
      end

      alias_method :filter=, :inclusion_filter=

      # Returns the `inclusion_filter`. If none has been set, returns an empty
      # hash.
      def inclusion_filter
        filter_manager.inclusions
      end

      alias_method :filter, :inclusion_filter

      # Adds key/value pairs to the `exclusion_filter`. If `args`
      # includes any symbols that are not part of the hash, each symbol
      # is treated as a key in the hash with the value `true`.
      #
      # ### Note
      #
      # Filters set using this method can be overridden from the command line
      # or config files (e.g. `.rspec`).
      #
      # @example
      #     # given this declaration
      #     describe "something", :foo => 'bar' do
      #       # ...
      #     end
      #
      #     # any of the following will exclude that group
      #     config.filter_run_excluding :foo => 'bar'
      #     config.filter_run_excluding :foo => /^ba/
      #     config.filter_run_excluding :foo => lambda {|v| v == 'bar'}
      #     config.filter_run_excluding :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     # given a proc with an arity of 1, the lambda is passed the value related to the key, e.g.
      #     config.filter_run_excluding :foo => lambda {|v| v == 'bar'}
      #
      #     # given a proc with an arity of 2, the lambda is passed the value related to the key,
      #     # and the metadata itself e.g.
      #     config.filter_run_excluding :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     filter_run_excluding :foo # same as filter_run_excluding :foo => true
      def filter_run_excluding(*args)
        filter_manager.exclude_with_low_priority Metadata.build_hash_from(args)
      end

      # Clears and reassigns the `exclusion_filter`. Set to `nil` if you don't
      # want any exclusion filter at all.
      #
      # ### Warning
      #
      # This overrides any exclusion filters/tags set on the command line or in
      # configuration files.
      def exclusion_filter=(filter)
        filter_manager.exclude! Metadata.build_hash_from([filter])
      end

      # Returns the `exclusion_filter`. If none has been set, returns an empty
      # hash.
      def exclusion_filter
        filter_manager.exclusions
      end

      # Tells RSpec to include `mod` in example groups. Methods defined in
      # `mod` are exposed to examples (not example groups).  Use `filters` to
      # constrain the groups in which to include the module.
      #
      # @example
      #
      #     module AuthenticationHelpers
      #       def login_as(user)
      #         # ...
      #       end
      #     end
      #
      #     module UserHelpers
      #       def users(username)
      #         # ...
      #       end
      #     end
      #
      #     RSpec.configure do |config|
      #       config.include(UserHelpers) # included in all modules
      #       config.include(AuthenticationHelpers, :type => :request)
      #     end
      #
      #     describe "edit profile", :type => :request do
      #       it "can be viewed by owning user" do
      #         login_as users(:jdoe)
      #         get "/profiles/jdoe"
      #         assert_select ".username", :text => 'jdoe'
      #       end
      #     end
      #
      # @see #extend
      def include(mod, *filters)
        include_or_extend_modules << [:include, mod, Metadata.build_hash_from(filters)]
      end

      # Tells RSpec to extend example groups with `mod`.  Methods defined in
      # `mod` are exposed to example groups (not examples).  Use `filters` to
      # constrain the groups to extend.
      #
      # Similar to `include`, but behavior is added to example groups, which
      # are classes, rather than the examples, which are instances of those
      # classes.
      #
      # @example
      #
      #     module UiHelpers
      #       def run_in_browser
      #         # ...
      #       end
      #     end
      #
      #     RSpec.configure do |config|
      #       config.extend(UiHelpers, :type => :request)
      #     end
      #
      #     describe "edit profile", :type => :request do
      #       run_in_browser
      #
      #       it "does stuff in the client" do
      #         # ...
      #       end
      #     end
      #
      # @see #include
      def extend(mod, *filters)
        include_or_extend_modules << [:extend, mod, Metadata.build_hash_from(filters)]
      end

      # @private
      #
      # Used internally to extend a group with modules using `include` and/or
      # `extend`.
      def configure_group(group)
        include_or_extend_modules.each do |include_or_extend, mod, filters|
          next unless filters.empty? || group.any_apply?(filters)
          __send__("safe_#{include_or_extend}", mod, group)
        end
      end

      # @private
      def safe_include(mod, host)
        host.__send__(:include, mod) unless host < mod
      end

      # @private
      def requires=(paths)
        directories = ['lib', default_path].select { |p| File.directory? p }
        RSpec::Core::RubyProject.add_to_load_path(*directories)
        paths.each {|path| require path}
        @requires += paths
      end

      # @private
      if RUBY_VERSION.to_f >= 1.9
        def safe_extend(mod, host)
          host.extend(mod) unless host.singleton_class < mod
        end
      else
        def safe_extend(mod, host)
          host.extend(mod) unless (class << host; self; end).included_modules.include?(mod)
        end
      end

      # @private
      def configure_mock_framework
        RSpec::Core::ExampleGroup.__send__(:include, mock_framework)
      end

      # @private
      def configure_expectation_framework
        expectation_frameworks.each do |framework|
          RSpec::Core::ExampleGroup.__send__(:include, framework)
        end
      end

      # @private
      def load_spec_files
        files_to_run.uniq.each {|f| load File.expand_path(f) }
        @spec_files_loaded = true
      end

      # @private
      DEFAULT_FORMATTER = lambda { |string| string }

      # Formats the docstring output using the block provided.
      #
      # @example
      #   # This will strip the descriptions of both examples and example groups.
      #   RSpec.configure do |config|
      #     config.format_docstrings { |s| s.strip }
      #   end
      def format_docstrings(&block)
        @format_docstrings_block = block_given? ? block : DEFAULT_FORMATTER
      end

      # @private
      def format_docstrings_block
        @format_docstrings_block ||= DEFAULT_FORMATTER
      end

      # @private
      def self.delegate_to_ordering_manager(*methods)
        methods.each do |method|
          define_method method do |*args, &block|
            ordering_manager.__send__(method, *args, &block)
          end
        end
      end

      # @macro delegate_to_ordering_manager
      #
      # Sets the seed value and sets the default global ordering to random.
      delegate_to_ordering_manager :seed=

      # @macro delegate_to_ordering_manager
      # Seed for random ordering (default: generated randomly each run).
      #
      # When you run specs with `--order random`, RSpec generates a random seed
      # for the randomization and prints it to the `output_stream` (assuming
      # you're using RSpec's built-in formatters). If you discover an ordering
      # dependency (i.e. examples fail intermittently depending on order), set
      # this (on Configuration or on the command line with `--seed`) to run
      # using the same seed while you debug the issue.
      #
      # We recommend, actually, that you use the command line approach so you
      # don't accidentally leave the seed encoded.
      delegate_to_ordering_manager :seed

      # @macro delegate_to_ordering_manager
      #
      # Sets the default global order and, if order is `'rand:<seed>'`, also sets the seed.
      delegate_to_ordering_manager :order=

      # @macro delegate_to_ordering_manager
      # Registers a named ordering strategy that can later be
      # used to order an example group's subgroups by adding
      # `:order => <name>` metadata to the example group.
      #
      # @param name [Symbol] The name of the ordering.
      # @yield Block that will order the given examples or example groups
      # @yieldparam list [Array<RSpec::Core::Example>, Array<RSpec::Core::ExampleGroup>] The examples or groups to order
      # @yieldreturn [Array<RSpec::Core::Example>, Array<RSpec::Core::ExampleGroup>] The re-ordered examples or groups
      #
      # @example
      #   RSpec.configure do |rspec|
      #     rspec.register_ordering :reverse do |list|
      #       list.reverse
      #     end
      #   end
      #
      #   describe MyClass, :order => :reverse do
      #     # ...
      #   end
      #
      # @note Pass the symbol `:global` to set the ordering strategy that
      #   will be used to order the top-level example groups and any example
      #   groups that do not have declared `:order` metadata.
      delegate_to_ordering_manager :register_ordering

      # @private
      delegate_to_ordering_manager :seed_used?, :ordering_registry

      # Set Ruby warnings on or off
      def warnings= value
        $VERBOSE = !!value
      end

      def warnings
        $VERBOSE
      end

      # Exposes the current running example via the named
      # helper method. RSpec 2.x exposed this via `example`,
      # but in RSpec 3.0, the example is instead exposed via
      # an arg yielded to `it`, `before`, `let`, etc. However,
      # some extension gems (such as Capybara) depend on the
      # RSpec 2.x's `example` method, so this config option
      # can be used to maintain compatibility.
      #
      # @param method_name [Symbol] the name of the helper method
      #
      # @example
      #
      #   RSpec.configure do |rspec|
      #     rspec.expose_current_running_example_as :example
      #   end
      #
      #   describe MyClass do
      #     before do
      #       # `example` can be used here because of the above config.
      #       do_something if example.metadata[:type] == "foo"
      #     end
      #   end
      def expose_current_running_example_as(method_name)
        ExposeCurrentExample.module_eval do
          extend RSpec::SharedContext
          let(method_name) { |ex| ex }
        end

        include ExposeCurrentExample
      end

      module ExposeCurrentExample; end

      # Turns deprecation warnings into errors, in order to surface
      # the full backtrace of the call site. This can be useful when
      # you need more context to address a deprecation than the
      # single-line call site normally provided.
      #
      # @example
      #
      #   RSpec.configure do |rspec|
      #     rspec.raise_errors_for_deprecations!
      #   end
      def raise_errors_for_deprecations!
        self.deprecation_stream = Formatters::DeprecationFormatter::RaiseErrorStream.new
      end

    private

      def get_files_to_run(paths)
        FlatMap.flat_map(paths) do |path|
          path = path.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
          File.directory?(path) ? gather_directories(path) : extract_location(path)
        end.sort
      end

      def gather_directories(path)
        stripped = "{#{pattern.gsub(/\s*,\s*/, ',')}}"
        files    = pattern =~ /^#{Regexp.escape path}/ ? Dir[stripped] : Dir["#{path}/#{stripped}"]
        files.sort
      end

      def extract_location(path)
        if path =~ /^(.*?)((?:\:\d+)+)$/
          path, lines = $1, $2[1..-1].split(":").map{|n| n.to_i}
          filter_manager.add_location path, lines
        end
        path
      end

      def command
        $0.split(File::SEPARATOR).last
      end

      def value_for(key, default=nil)
        @preferred_options.has_key?(key) ? @preferred_options[key] : default
      end

      def assert_no_example_groups_defined(config_option)
        if RSpec.world.example_groups.any?
          raise MustBeConfiguredBeforeExampleGroupsError.new(
            "RSpec's #{config_option} configuration option must be configured before " +
            "any example groups are defined, but you have already defined a group."
          )
        end
      end

      def output_to_tty?(output=output_stream)
        tty? || (output.respond_to?(:tty?) && output.tty?)
      end
    end
  end
end
