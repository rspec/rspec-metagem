require 'autotest'

class RSpecCommandError < StandardError; end

class Autotest::Rspec2 < Autotest

  SPEC_PROGRAM = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'rspec'))

  def initialize
    super
    clear_mappings
    setup_rspec_project_mappings
    self.failed_results_re = /^\d+\)\n(?:\e\[\d*m)?(?:.*?in )?'([^\n]*)'(?: FAILED)?(?:\e\[\d*m)?\n\n?(.*?(\n\n\(.*?)?)\n\n/m
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
      if trace =~ /\n(\.\/)?(.*spec\.rb):[\d]+:/
        filters[$2] << spec
      end
    end
    return filters
  end

  def make_test_cmd(files_to_test)
    files_to_test.empty? ? '' :
      "#{ruby} #{require_rubygems}#{SPEC_PROGRAM} #{normalize(files_to_test).keys.flatten.join(' ')}"
  end

  def require_rubygems
    defined?(:Gem) ? "-rrubygems " : ""
  end

  def normalize(files_to_test)
    files_to_test.keys.inject({}) do |result, filename|
      result[File.expand_path(filename)] = []
      result
    end
  end

end
