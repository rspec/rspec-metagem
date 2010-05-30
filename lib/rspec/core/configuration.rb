module RSpec
  module Core
    class Configuration
      def self.add_setting(name, opts={})
        if opts[:alias]
          alias_method name, opts[:alias]
          alias_method "#{name}=", "#{opts[:alias]}="
          alias_method "#{name}?", "#{opts[:alias]}?"
        else
          define_method("#{name}=") {|val| settings[name] = val}
          define_method(name) { settings.has_key?(name) ? settings[name] : opts[:default] }
          define_method("#{name}?") { !!(send name) }
        end
      end

      add_setting :error_stream
      add_setting :output_stream
      add_setting :output, :alias => :output_stream
      add_setting :color_enabled
      add_setting :profile_examples
      add_setting :run_all_when_everything_filtered
      add_setting :mock_framework, :default => :rspec
      add_setting :filter
      add_setting :exclusion_filter
      add_setting :filename_pattern, :default => '**/*_spec.rb'
      add_setting :files_to_run, :default => []
      add_setting :include_or_extend_modules, :default => []
      add_setting :formatter_class, :default => RSpec::Core::Formatters::ProgressFormatter
      add_setting :backtrace_clean_patterns, :default => [
        /\/lib\/ruby\//, 
        /bin\/rcov:/, 
        /vendor\/rails/, 
        /bin\/rspec/, 
        /bin\/spec/,
        /lib\/rspec\/(core|expectations|matchers|mocks)/
      ]
    
      # :call-seq:
      #   add_setting(:name)
      #   add_setting(:name, :default => "default_value")
      #   add_setting(:name, :alias => :other_setting)
      #
      # Use this to add custom settings to the RSpec.configuration object. 
      #
      #   RSpec.configuration.add_setting :foo
      #
      # Creates three methods on the configuration object, a setter, a getter,
      # and a predicate:
      #
      #   RSpec.configuration.foo=(value)
      #   RSpec.configuration.foo()
      #   RSpec.configuration.foo?() # returns !!foo
      #
      # Intended for extension frameworks like rspec-rails, so they can add config
      # settings that are domain specific. For example:
      #
      #   RSpec.configure do |c|
      #     c.add_setting :use_transactional_fixtures, :default => true
      #     c.add_setting :use_transactional_examples, :alias => :use_transactional_fixtures
      #   end
      #
      # == Options
      # 
      # +add_setting+ takes an optional hash that supports the following
      # keys:
      #
      #   :default => "default value"
      #
      # This sets the default value for the getter and the predicate (which
      # will return +true+ as long as the value is not +false+ or +nil+).
      #
      #   :alias => :other_setting
      #
      # Aliases its setter, getter, and predicate, to those for the
      # +other_setting+.
      def add_setting(name, opts={})
        self.class.add_setting(name, opts)
      end

      def hooks
        @hooks ||= { 
          :before => { :each => [], :all => [], :suite => [] }, 
          :after => { :each => [], :all => [], :suite => [] } 
        }
      end

      def settings
        @settings ||= {}
      end

      def clear_inclusion_filter
        self.filter = nil
      end

      def cleaned_from_backtrace?(line)
        backtrace_clean_patterns.any? { |regex| line =~ regex }
      end

      def require_mock_framework_adapter
        require case mock_framework.to_s
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
      end

      def full_backtrace=(bool)
        backtrace_clean_patterns.clear
      end

      def libs=(libs)
        libs.map {|lib| $LOAD_PATH.unshift lib}
      end

      def debug=(bool)
        return unless bool
        begin
          require 'ruby-debug'
        rescue LoadError
          raise <<-EOM

#{'*'*50}
You must install ruby-debug to run rspec with the --debug option.

If you have ruby-debug installed as a ruby gem, then you need to either
require 'rubygems' or configure the RUBYOPT environment variable with
the value 'rubygems'.
#{'*'*50}
EOM
        end
      end

      def line_number=(line_number)
        filter_run :line_number => line_number.to_i
      end

      def full_description=(description)
        filter_run :full_description => /#{description}/
      end
      
      def formatter=(formatter_to_use)
        formatter_class = case formatter_to_use.to_s
        when 'd', 'doc', 'documentation', 's', 'n', 'spec', 'nested'
          RSpec::Core::Formatters::DocumentationFormatter
        when 'progress' 
          RSpec::Core::Formatters::ProgressFormatter
        else 
          raise ArgumentError, "Formatter '#{formatter_to_use}' unknown - maybe you meant 'documentation' or 'progress'?."
        end
        self.formatter_class = formatter_class
      end

      def formatter
        @formatter ||= formatter_class.new
      end

      def files_or_directories_to_run=(*files)
        self.files_to_run = files.flatten.inject([]) do |result, file|
          if File.directory?(file)
            filename_pattern.split(",").each do |pattern|
              result += Dir["#{file}/#{pattern.strip}"]
            end
          else
            path, line_number = file.split(':')
            self.line_number = line_number if line_number
            result << path
          end
          result
        end
      end

      # E.g. alias_example_to :crazy_slow, :speed => 'crazy_slow' defines
      # crazy_slow as an example variant that has the crazy_slow speed option
      def alias_example_to(new_name, extra_options={})
        RSpec::Core::ExampleGroup.alias_example_to(new_name, extra_options)
      end

      def filter_run(options={})
        self.filter = options unless filter and filter[:line_number] || filter[:full_description]
      end

      def include(mod, filters={})
        include_or_extend_modules << [:include, mod, filters]
      end

      def extend(mod, filters={})
        include_or_extend_modules << [:extend, mod, filters]
      end

      def find_modules(group)
        include_or_extend_modules.select do |include_or_extend, mod, filters|
          group.all_apply?(filters)
        end
      end

      def before(each_or_all=:each, options={}, &block)
        hooks[:before][each_or_all] << [options, block]
      end

      def after(each_or_all=:each, options={}, &block)
        hooks[:after][each_or_all] << [options, block]
      end

      def find_hook(hook, each_or_all, group)
        hooks[hook][each_or_all].select do |filters, block|
          group.all_apply?(filters)
        end.map { |filters, block| block }
      end

      def configure_mock_framework
        require_mock_framework_adapter
        RSpec::Core::ExampleGroup.send(:include, RSpec::Core::MockFrameworkAdapter)
      end

      def require_files_to_run
        files_to_run.map {|f| require File.expand_path(f) }
      end
    end
  end
end
