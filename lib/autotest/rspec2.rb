require 'autotest'
require 'rspec/core/deprecation'

class RSpecCommandError < StandardError; end

class Autotest::Rspec2 < Autotest

  attr_reader :cli_args, :skip_bundler
  alias_method :skip_bundler?, :skip_bundler

  SPEC_PROGRAM = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'rspec'))

  def initialize
    super()
    @cli_args = ARGV.dup << "--tty"
    @skip_bundler = @cli_args.delete("--skip-bundler")
    ARGV.clear
    clear_mappings
    setup_rspec_project_mappings

    # Example for Ruby 1.8: http://rubular.com/r/AOXNVDrZpx
    # Example for Ruby 1.9: http://rubular.com/r/85ag5AZ2jP
    self.failed_results_re = /^\s*\d+\).*\n\s+Failure.*(\n\s+#\s(.*)?:\d+(?::.*)?)+$/m
    self.completed_re = /\n(?:\e\[\d*m)?\d* examples?/m
  end

  def setup_rspec_project_mappings
    add_mapping(%r%^spec/.*_spec\.rb$%) { |filename, _|
      filename
    }
    add_mapping(%r%^lib/(.*)\.rb$%) { |_, m|
      ["spec/#{m[1]}_spec.rb"]
    }
    add_mapping(%r%^spec/(spec_helper|shared/.*)\.rb$%) {
      files_matching %r%^spec/.*_spec\.rb$%
    }
  end

  def consolidate_failures(failed)
    filters = new_hash_of_arrays
    failed.each do |spec, trace|
      if trace =~ /(.*spec\.rb)/
        filters[$1] << spec
      end
    end
    return filters
  end

  def make_test_cmd(files_to_test)
    if File.exist?('./Gemfile') && prefix !~ /bundle exec/ && !skip_bundler?
      RSpec.warn_deprecation <<-WARNING

****************************************************************************
DEPRECATION WARNING: you are using deprecated behaviour that will be removed
from a future version of RSpec.

RSpec's autotest extension is relying on the presence of a Gemfile in the
project root directory to generate a command including 'bundle exec'.

You have two options to disable this message:

If you want to include 'bundle exec' in the command, add a .autotest file to
the project root with the following content:

  require 'autotest/bundler'

If you prefer to skip 'bundle exec', pass the --skip-bundler to autotest as
an extra argument, like this:

  autotest -- --skip-bundler
*****************************************************************
WARNING
    end
    files_to_test.empty? ? '' :
      "#{prefix}#{bundle_exec}#{ruby} #{require_rubygems}-S #{SPEC_PROGRAM} #{cli_args.join(' ')} #{normalize(files_to_test).keys.flatten.map { |f| "'#{f}'"}.join(' ')}"
  end

  def bundle_exec
    if using_bundler? && prefix !~ /bundle exec/
      "bundle exec "
    else
      ""
    end
  end

  def require_rubygems
    using_bundler? ? "" : defined?(:Gem) ? "-rrubygems " : " "
  end

  def normalize(files_to_test)
    files_to_test.keys.inject({}) do |result, filename|
      result[File.expand_path(filename)] = []
      result
    end
  end

  def using_bundler?
    gemfile?  unless skip_bundler?
  end

  def gemfile?
    File.exist?('./Gemfile')
  end

end
