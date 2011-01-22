require 'autotest'
require 'rspec/core/deprecation'

class RSpecCommandError < StandardError; end

class Autotest::Rspec2 < Autotest

  attr_reader :cl_args, :skip_bundler
  alias_method :skip_bundler?, :skip_bundler

  SPEC_PROGRAM = File.expand_path('../../../bin/rspec', __FILE__)

  def initialize
    super()
    @cl_args = ARGV.dup << "--tty"
    @skip_bundler = @cl_args.delete("--skip-bundler")
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
    warn_about_bundler if rspec_wants_bundler? && !autotest_wants_bundler?
    files_to_test.empty? ? '' :
      "#{prefix}#{ruby}#{suffix} -S #{SPEC_PROGRAM} #{cl_args.join(' ')} #{normalize(files_to_test).keys.flatten.map { |f| "'#{f}'"}.join(' ')}"
  end

  def normalize(files_to_test)
    files_to_test.keys.inject({}) do |result, filename|
      result[File.expand_path(filename)] = []
      result
    end
  end

  def warn_about_bundler
    RSpec.warn_deprecation <<-WARNING

****************************************************************************
DEPRECATION WARNING: you are using deprecated behaviour that will be removed
from a future version of RSpec.

RSpec's autotest extension is relying on the presence of a Gemfile in the
project root directory to generate a command including 'bundle exec'.

You have two options to suppress this message:

If you want to include 'bundle exec' in the command, add a .autotest file to
the project root with the following content:

  require 'autotest/bundler'

If you want to _not_include 'bundle exec' in the command, pass --skip-bundler
to autotest as an extra argument, like this:

  autotest -- --skip-bundler
*****************************************************************
WARNING
  end

  alias_method :autotest_prefix, :prefix

  def rspec_prefix
    (rspec_wants_bundler? && !autotest_wants_bundler?) ? "bundle exec " : ""
  end

  def prefix
    skip_bundler? ? "#{rspec_prefix}#{autotest_prefix}".gsub("bundle exec","") : "#{rspec_prefix}#{autotest_prefix}"
  end

  def autotest_wants_bundler?
    autotest_prefix =~ /bundle exec/
  end

  def suffix
    using_bundler? ? "" : defined?(:Gem) ? " -rrubygems" : ""
  end

  def rspec_wants_bundler?
    gemfile? && !skip_bundler?
  end

  def using_bundler?
    rspec_wants_bundler? || autotest_wants_bundler?
  end

  def gemfile?
    File.exist?('./Gemfile')
  end

end
