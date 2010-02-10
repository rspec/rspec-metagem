require 'rspec/core/load_path'
require 'rspec/core/deprecation'
require 'rspec/core/mocking/with_absolutely_nothing'
require 'rspec/core/around_proxy'
require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/command_line_options'
require 'rspec/core/runner'
require 'rspec/core/example'
require 'rspec/core/metadata'
require 'rspec/core/kernel_extensions'
require 'rspec/core/shared_example_group'
require 'rspec/core/example_group_subject'
require 'rspec/core/example_group'
require 'rspec/core/formatters'
require 'rspec/core/backward_compatibility'
require 'rspec/core/version'

module Rspec
  module Core

    def self.install_directory
      @install_directory ||= File.expand_path(File.dirname(__FILE__))
    end

    def self.configuration
      @configuration ||= Rspec::Core::Configuration.new
    end

    def self.configure
      yield configuration if block_given?
    end

    def self.world
      @world ||= Rspec::Core::World.new
    end

  end
end
