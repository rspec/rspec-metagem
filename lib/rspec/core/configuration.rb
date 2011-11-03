require "rbconfig"
require 'fileutils'

module RSpec
  module Core
    class Configuration
      include RSpec::Core::Hooks

      class MustBeConfiguredBeforeExampleGroupsError < StandardError; end

      def self.define_predicate_for(name)
        alias_method "#{name}?", name
      end

      # @api private
      #
      # Invoked by the `add_setting` instance method. Use that method on a
      # `Configuration` instance rather than this class method.
      def self.add_setting(name, opts={})
        raise "Use the instance add_setting method if you want to set a default" if opts.has_key?(:default)
        if opts[:alias]
          RSpec.warn_deprecation <<-MESSAGE
The :alias option to add_setting is deprecated. Use :alias_with on the original setting instead.
Called from #{caller(0)[4]}
MESSAGE
          alias_method name, opts[:alias]
          alias_method "#{name}=", "#{opts[:alias]}="
          define_predicate_for name
        else
          attr_accessor name
          define_predicate_for name
        end
        if opts[:alias_with]
          [opts[:alias_with]].flatten.each do |alias_name|
            alias_method alias_name, name
            alias_method "#{alias_name}=", "#{name}="
            define_predicate_for alias_name
          end
        end
      end

      add_setting :error_stream
      add_setting :output_stream, :alias_with => [:output, :out]
      add_setting :drb
      add_setting :drb_port
      add_setting :profile_examples
      add_setting :fail_fast
      add_setting :failure_exit_code
      add_setting :run_all_when_everything_filtered
      add_setting :pattern, :alias_with => :filename_pattern
      add_setting :files_to_run
      add_setting :include_or_extend_modules
      add_setting :backtrace_clean_patterns
      add_setting :tty
      add_setting :treat_symbols_as_metadata_keys_with_true_values
      add_setting :expecting_with_rspec
      add_setting :default_path
      add_setting :show_failures_in_pending_blocks
      add_setting :order

      DEFAULT_EXCLUSION_FILTERS = {
        :if     => lambda { |value, metadata| metadata.has_key?(:if) && !value },
        :unless => lambda { |value| value }
      }

      DEFAULT_BACKTRACE_PATTERNS = [
        /\/lib\d*\/ruby\//,
        /org\/jruby\//,
        /bin\//,
        /gems/,
        /spec\/spec_helper\.rb/,
        /lib\/rspec\/(core|expectations|matchers|mocks)/
      ]

      def initialize
        @expectation_frameworks = []
        @include_or_extend_modules = []
        @mock_framework = nil
        @files_to_run = []
        @formatters = []
        @color_enabled = false
        @pattern = '**/*_spec.rb'
        @failure_exit_code = 1
        @backtrace_clean_patterns = DEFAULT_BACKTRACE_PATTERNS.dup
        @default_path = 'spec'
        @exclusion_filter = DEFAULT_EXCLUSION_FILTERS.dup
        @seed = srand % 0xFFFF
      end

      def reset
        @reporter = nil
        @formatters.clear
      end

      # @overload add_setting(name)
      # @overload add_setting(name, options_hash)
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
      #
      # ### Options
      #
      # `add_setting` takes an optional hash that supports the keys `:default`
      # and `:alias_with`.
      #
      # Use `:default` to set a default value for the generated getter and
      # predicate methods:
      #
      #     add_setting(:foo, :default => "default value")
      #
      # Use `:alias_with` to alias the setter, getter, and predicate to another
      # name, or names:
      #
      #     add_setting(:foo, :alias_with => :bar)
      #     add_setting(:foo, :alias_with => [:bar, :baz])
      #
      def add_setting(name, opts={})
        default = opts.delete(:default)
        (class << self; self; end).class_eval do
          add_setting(name, opts)
        end
        send("#{name}=", default) if default
      end

      # Used by formatters to ask whether a backtrace line should be displayed
      # or not, based on the line matching any `backtrace_clean_patterns`.
      def cleaned_from_backtrace?(line)
        backtrace_clean_patterns.any? { |regex| line =~ regex }
      end

      # Returns the configured mock framework adapter module
      def mock_framework
        @mock_framework ||= begin
                              require 'rspec/core/mocking/with_rspec'
                              RSpec::Core::MockFrameworkAdapter
                            end
      end

      # Delegates to mock_framework=(framework)
      def mock_framework=(framework)
        mock_with framework
      end

      # Sets the mock framework adapter module.
      #
      # `framework` can be a Symbol or a Module.
      #
      # Given any of :rspec, :mocha, :flexmock, or :rr, configures the named
      # framework.
      #
      # Given :nothing, configures no framework. Use this if you don't use any
      # mocking framework to save a little bit of overhead.
      #
      # Given a Module, includes that module in every example group. The module
      # should adhere to RSpec's mock framework adapter API:
      #
      #   setup_mocks_for_rspec
      #     - called before each example
      #
      #   verify_mocks_for_rspec
      #     - called after each example. Framework should raise an exception
      #       when expectations fail
      #
      #   teardown_mocks_for_rspec
      #     - called after verify_mocks_for_rspec (even if there are errors)
      def mock_with(framework)
        assert_no_example_groups_defined(:mock_framework)
        case framework
        when Module
          @mock_framework = framework
        when String, Symbol
          require case framework.to_s
                  when /rspec/i
                    'rspec/core/mocking/with_rspec'
                  when /mocha/i
                    'rspec/core/mocking/with_mocha'
                  when /rr/i
                    'rspec/core/mocking/with_rr'
                  when /flexmock/i
                    'rspec/core/mocking/with_flexmock'
                  else
                    'rspec/core/mocking/with_absolutely_nothing'
                  end
          @mock_framework = RSpec::Core::MockFrameworkAdapter
        end
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

      # Sets the expectation framework module(s).
      #
      # `frameworks` can be :rspec, :stdlib, or both
      #
      # Given :rspec, configures rspec/expectations.
      # Given :stdlib, configures test/unit/assertions
      # Given both, configures both
      def expect_with(*frameworks)
        assert_no_example_groups_defined(:expect_with)
        @expectation_frameworks.clear

        modules = frameworks.map do |framework|
          case framework
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

        @expectation_frameworks.push(*modules)
      end

      def full_backtrace=(true_or_false)
        @backtrace_clean_patterns = true_or_false ? [] : DEFAULT_BACKTRACE_PATTERNS
      end

      def color_enabled
        @color_enabled && output_to_tty?
      end

      define_predicate_for :color_enabled

      def color_enabled=(bool)
        return unless bool
        @color_enabled = true
        if bool && ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
          unless ENV['ANSICON']
            warn "You must use ANSICON 1.31 or later (http://adoxa.110mb.com/ansicon/) to use colour on Windows"
            @color_enabled = false
          end
        end
      end

      def libs=(libs)
        libs.map {|lib| $LOAD_PATH.unshift lib}
      end

      def requires=(paths)
        paths.map {|path| require path}
      end

      def debug=(bool)
        return unless bool
        begin
          require 'ruby-debug'
          Debugger.start
        rescue LoadError => e
          raise <<-EOM

#{'*'*50}
#{e.message}

If you have it installed as a ruby gem, then you need to either require
'rubygems' or configure the RUBYOPT environment variable with the value
'rubygems'.

#{e.backtrace.join("\n")}
#{'*'*50}
EOM
        end
      end

      # Run examples defined on `line_numbers` in all files to run.
      def line_numbers=(line_numbers)
        filter_run :line_numbers => line_numbers.map{|l| l.to_i}
      end

      def full_description=(description)
        filter_run :full_description => /#{description}/
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
      # and path to a file that contains that class definition, but you should
      # consider that a private api that may change at any time without notice.
      def add_formatter(formatter_to_use, path=nil)
        formatter_class =
          built_in_formatter(formatter_to_use) ||
          custom_formatter(formatter_to_use) ||
          (raise ArgumentError, "Formatter '#{formatter_to_use}' unknown - maybe you meant 'documentation' or 'progress'?.")

        formatters << formatter_class.new(path ? file_at(path) : output)
      end

      alias_method :formatter=, :add_formatter

      def formatters
        @formatters ||= []
      end

      def reporter
        @reporter ||= begin
                        add_formatter('progress') if formatters.empty?
                        Reporter.new(*formatters)
                      end
      end

      def files_or_directories_to_run=(*files)
        files = files.flatten
        files << default_path if command == 'rspec' && default_path && files.empty?
        self.files_to_run = get_files_to_run(files)
      end

      # @api private
      def command
        $0.split(File::SEPARATOR).last
      end

      # @api private
      def get_files_to_run(files)
        patterns = pattern.split(",")
        files.map do |file|
          if File.directory?(file)
            patterns.map do |pattern|
              if pattern =~ /^#{file}/
                Dir[pattern.strip]
              else
                Dir["#{file}/{#{pattern.strip}}"]
              end
            end
          else
            if file =~ /^(.*?)((?:\:\d+)+)$/
              path, lines = $1, $2[1..-1].split(":").map{|n| n.to_i}
              add_location path, lines
              path
            else
              file
            end
          end
        end.flatten
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
        extra_options = build_metadata_hash_from(args)
        RSpec::Core::ExampleGroup.alias_example_to(new_name, extra_options)
      end

      # Define an alias for it_should_behave_like that allows different
      # language (like "it_has_behavior" or "it_behaves_like") to be
      # employed when including shared examples.
      #
      # Example:
      #
      #     alias_it_should_behave_like_to(:it_has_behavior, 'has behavior:')
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
      def alias_it_should_behave_like_to(new_name, report_label = '')
        RSpec::Core::ExampleGroup.alias_it_should_behave_like_to(new_name, report_label)
      end

      # Adds key/value pairs to the `inclusion_filter`. If the
      # `treat_symbols_as_metadata_keys_with_true_values` config option is set
      # to true and `args` includes any symbols that are not part of a hash,
      # each symbol is treated as a key in the hash with the value `true`.
      #
      # @example
      #     filter_run_including :x => 'y'
      #
      #     # with treat_symbols_as_metadata_keys_with_true_values = true
      #     filter_run_including :foo # results in {:foo => true}
      def filter_run_including(*args)
        filter = build_metadata_hash_from(args)
        if already_set_standalone_filter?
          warn_already_set_standalone_filter(filter)
        elsif contains_standalone_filter?(filter)
          inclusion_filter.replace(filter)
        else
          inclusion_filter.merge!(filter)
        end
      end

      alias_method :filter_run, :filter_run_including

      # Clears and reassigns the `inclusion_filter`. Set to `nil` if you don't
      # want any inclusion filter at all.
      def inclusion_filter=(filter)
        filter = build_metadata_hash_from([filter])
        filter.empty? ? inclusion_filter.clear : inclusion_filter.replace(filter)
      end

      alias_method :filter=, :inclusion_filter=

      # Returns the `inclusion_filter`. If none has been set, returns an empty
      # hash.
      def inclusion_filter
        @inclusion_filter ||= {}
      end

      alias_method :filter, :inclusion_filter

      # Adds key/value pairs to the `exclusion_filter`. If the
      # `treat_symbols_as_metadata_keys_with_true_values` config option is set
      # to true and `args` excludes any symbols that are not part of a hash,
      # each symbol is treated as a key in the hash with the value `true`.
      #
      # @example
      #     filter_run_excluding :x => 'y'
      #
      #     # with treat_symbols_as_metadata_keys_with_true_values = true
      #     filter_run_excluding :foo # results in {:foo => true}
      def filter_run_excluding(*args)
        exclusion_filter.merge!(build_metadata_hash_from(args))
      end

      # Clears and reassigns the `exclusion_filter`. Set to `nil` if you don't
      # want any exclusion filter at all.
      def exclusion_filter=(filter)
        filter = build_metadata_hash_from([filter])
        filter.empty? ? exclusion_filter.clear : exclusion_filter.replace(filter)
      end

      # Returns the `exclusion_filter`. If none has been set, returns an empty
      # hash.
      def exclusion_filter
        @exclusion_filter ||= {}
      end

      STANDALONE_FILTERS = [:line_numbers, :full_description]

      # @api private
      def already_set_standalone_filter?
        contains_standalone_filter?(inclusion_filter)
      end

      # @api private
      def contains_standalone_filter?(filter)
        STANDALONE_FILTERS.any? {|key| filter.has_key?(key)}
      end

      def include(mod, *args)
        filters = build_metadata_hash_from(args)
        include_or_extend_modules << [:include, mod, filters]
      end

      def extend(mod, *args)
        filters = build_metadata_hash_from(args)
        include_or_extend_modules << [:extend, mod, filters]
      end

      # @api private
      #
      # Used internally to extend a group with modules using `include` and/or
      # `extend`.
      def configure_group(group)
        include_or_extend_modules.each do |include_or_extend, mod, filters|
          next unless filters.empty? || group.any_apply?(filters)
          group.send(include_or_extend, mod)
        end
      end

      def configure_mock_framework
        RSpec::Core::ExampleGroup.send(:include, mock_framework)
      end

      def configure_expectation_framework
        expectation_frameworks.each do |framework|
          RSpec::Core::ExampleGroup.send(:include, framework)
        end
      end

      def load_spec_files
        files_to_run.map {|f| load File.expand_path(f) }
        raise_if_rspec_1_is_loaded
      end

      attr_reader :seed

      def seed=(seed)
        @order = 'rand'
        @seed = seed.to_i
      end

      def randomize?
        order.to_s.match(/rand/)
      end

      def order=(type)
        order, seed = type.to_s.split(':')
        if order == 'default'
          @order = nil
          @seed = nil
        else
          @order = order
          @seed = seed.to_i if seed
        end
      end

    private

      def add_location(file_path, line_numbers)
        # filter_locations is a hash of expanded paths to arrays of line
        # numbers to match against.
        filter_locations = ((self.filter || {})[:locations] ||= {})
        (filter_locations[File.expand_path(file_path)] ||= []).push(*line_numbers)
        filter_run(:locations => filter_locations)
      end

      def warn_already_set_standalone_filter(options)
        warn "Filtering by #{options.inspect} is not possible since " \
          "you are already filtering by #{inclusion_filter.inspect}"
      end

      def assert_no_example_groups_defined(config_option)
        if RSpec.world.example_groups.any?
          raise MustBeConfiguredBeforeExampleGroupsError.new(
            "RSpec's #{config_option} configuration option must be configured before " +
            "any example groups are defined, but you have already defined a group."
          )
        end
      end

      def raise_if_rspec_1_is_loaded
        if defined?(Spec) && defined?(Spec::VERSION::MAJOR) && Spec::VERSION::MAJOR == 1
          raise <<-MESSAGE

#{'*'*80}
  You are running rspec-2, but it seems as though rspec-1 has been loaded as
  well.  This is likely due to a statement like this somewhere in the specs:

      require 'spec'

  Please locate that statement, remove it, and try again.
#{'*'*80}
MESSAGE
        end
      end

      def output_to_tty?
        begin
          output_stream.tty? || tty?
        rescue NoMethodError
          false
        end
      end

      def built_in_formatter(key)
        case key.to_s
        when 'd', 'doc', 'documentation', 's', 'n', 'spec', 'nested'
          require 'rspec/core/formatters/documentation_formatter'
          RSpec::Core::Formatters::DocumentationFormatter
        when 'h', 'html'
          require 'rspec/core/formatters/html_formatter'
          RSpec::Core::Formatters::HtmlFormatter
        when 't', 'textmate'
          require 'rspec/core/formatters/text_mate_formatter'
          RSpec::Core::Formatters::TextMateFormatter
        when 'p', 'progress'
          require 'rspec/core/formatters/progress_formatter'
          RSpec::Core::Formatters::ProgressFormatter
        end
      end

      def custom_formatter(formatter_ref)
        if Class === formatter_ref
          formatter_ref
        elsif string_const?(formatter_ref)
          begin
            eval(formatter_ref)
          rescue NameError
            require path_for(formatter_ref)
            eval(formatter_ref)
          end
        end
      end

      def string_const?(str)
        str.is_a?(String) && /\A[A-Z][a-zA-Z0-9_:]*\z/ =~ str
      end

      def path_for(const_ref)
        underscore_with_fix_for_non_standard_rspec_naming(const_ref)
      end

      def underscore_with_fix_for_non_standard_rspec_naming(string)
        underscore(string).sub(%r{(^|/)r_spec($|/)}, '\\1rspec\\2')
      end

      # activesupport/lib/active_support/inflector/methods.rb, line 48
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

      def file_at(path)
        FileUtils.mkdir_p(File.dirname(path))
        File.new(path, 'w')
      end

    end
  end
end
