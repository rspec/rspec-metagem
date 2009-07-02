require 'rspec/core/deprecation'
require 'rspec/core/mocking/with_absolutely_nothing'
require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/runner'
require 'rspec/core/example'
require 'rspec/core/shared_behaviour'
require 'rspec/core/example_group'
require 'rspec/core/kernel_extensions'
require 'rspec/core/formatters'

module Rspec
  module Core

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
