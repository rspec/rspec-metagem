module RSpec
  module Core
    class Configuration
      attr_reader :hooks # :nodoc:

      # Control what examples are run by filtering 
      attr_accessor :filter

      # Control what examples are not run by filtering 
      attr_accessor :exclusion_filter

      # Run all examples if the run is filtered, and no examples were found.
      attr_writer :run_all_when_everything_filtered

      attr_reader :options

      def initialize
        @run_all_when_everything_filtered = false
        @hooks = { 
          :before => { :each => [], :all => [], :suite => [] }, 
          :after => { :each => [], :all => [], :suite => [] } 
        }
        @include_or_extend_modules = []
        @filter, @exclusion_filter = nil, nil
        @options = default_options
      end
      
      def default_options
        {
          :color_enabled => false,
          :mock_framework => nil,
          :profile_examples => false,
          :files_to_run => [],
          :filename_pattern => '**/*_spec.rb',
          :formatter_class => RSpec::Core::Formatters::ProgressFormatter,
          :backtrace_clean_patterns => [/\/lib\/ruby\//, 
                                        /bin\/rcov:/, 
                                        /vendor\/rails/, 
                                        /bin\/rspec/, 
                                        /bin\/spec/,
                                        /lib\/rspec\/(core|expectations|matchers|mocks)/]
        }
      end

      def clear_inclusion_filter
        self.filter = nil
      end
      
      def cleaned_from_backtrace?(line)
        @options[:backtrace_clean_patterns].any? { |regex| line =~ regex }
      end

      def backtrace_clean_patterns
        @options[:backtrace_clean_patterns]
      end

      def mock_framework=(use_me_to_mock)
        @options[:mock_framework] = use_me_to_mock
      end

      def require_mock_framework_adapter
        require case @options[:mock_framework].to_s
        when "", /rspec/i
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

      def filename_pattern
        @options[:filename_pattern]
      end

      def filename_pattern=(new_pattern)
        @options[:filename_pattern] = new_pattern
      end 

      def color_enabled=(on_or_off)
        @options[:color_enabled] = on_or_off
      end

      def full_backtrace=(bool)
        @options[:backtrace_clean_patterns].clear
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

      def color_enabled?
        @options[:color_enabled]
      end

      def line_number=(line_number)
        filter_run :line_number => line_number.to_i
      end

      def full_description=(description)
        filter_run :full_description => /#{description}/
      end
      
      # Enable profiling of example run - defaults to false
      def profile_examples
        @options[:profile_examples]
      end
      
      def profile_examples=(on_or_off)
        @options[:profile_examples] = on_or_off
      end
     
      def formatter_class
        @options[:formatter_class]
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
        @options[:formatter_class] = formatter_class
      end
        
      def formatter
        @formatter ||= formatter_class.new
      end
      
      def files_to_run
        @options[:files_to_run]
      end
      
      def files_or_directories_to_run=(*files)
        @options[:files_to_run] = files.flatten.inject([]) do |result, file|
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
        @filter = options unless @filter and @filter[:line_number] || @filter[:full_description]
      end

      def run_all_when_everything_filtered?
        @run_all_when_everything_filtered
      end

      def output
        $stdout
      end

      def puts(msg="")
        output.puts(msg)    
      end

      def include(mod, options={})
        @include_or_extend_modules << [:include, mod, options]
      end

      def extend(mod, options={})
        @include_or_extend_modules << [:extend, mod, options]
      end

      def find_modules(group)
        @include_or_extend_modules.select do |include_or_extend, mod, filters|
          group.all_apply?(filters)
        end
      end

      def before(each_or_all=:each, options={}, &block)
        @hooks[:before][each_or_all] << [options, block]
      end

      def after(each_or_all=:each, options={}, &block)
        @hooks[:after][each_or_all] << [options, block]
      end

      def find_hook(hook, each_or_all, group)
        @hooks[hook][each_or_all].select do |filters, block|
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

      def add_option(mname, options)
        case options[:type]
        when :boolean
          (class << self; self; end).class_eval do
            attr_accessor mname
            define_method("#{mname}?") { !!(send mname) }
          end
          instance_variable_set "@#{mname}", options[:default]
        end
      end

    end
  end
end
