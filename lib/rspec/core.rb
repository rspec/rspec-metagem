require 'rspec/core/kernel_extensions'
require 'rspec/core/object_extensions'
require 'rspec/core/load_path'
require 'rspec/core/deprecation'

require 'rspec/core/hooks'
require 'rspec/core/subject'
require 'rspec/core/let'
require 'rspec/core/metadata'
require 'rspec/core/pending'

require 'rspec/core/around_proxy'
require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/configuration_options'
require 'rspec/core/runner'
require 'rspec/core/example'
require 'rspec/core/shared_example_group'
require 'rspec/core/example_group'
require 'rspec/core/formatters'
require 'rspec/core/backward_compatibility'
require 'rspec/core/version'
require 'rspec/core/errors'

module Rspec
  module Core

    def self.install_directory
      @install_directory ||= File.expand_path(File.dirname(__FILE__))
    end

    def self.configuration
      Rspec.deprecate('Rspec::Core.configuration', 'Rspec.configuration', '2.0.0')
      Rspec.configuration
    end

    def self.configure
      Rspec.deprecate('Rspec::Core.configure', 'Rspec.configure', '2.0.0')
      yield Rspec.configuration if block_given?
    end

    def self.world
      @world ||= Rspec::Core::World.new
    end

  end

  def self.configuration
    @configuration ||= Rspec::Core::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end

# TODO - make this configurable with default 'on'
require 'rspec/expectations'
