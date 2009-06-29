require 'spec/core/mocking/with_absolutely_nothing'
require 'spec/core/world'
require 'spec/core/configuration'
require 'spec/core/runner'
require 'spec/core/example'
require 'spec/core/behaviour'
require 'spec/core/kernel_extensions'
require 'spec/core/formatters'

module Spec
  module Core

    def self.configuration
      @configuration ||= Spec::Core::Configuration.new
    end

    def self.configure
      yield configuration if block_given?
    end
  
    def self.world
      @world ||= Spec::Core::World.new
    end
    
  end
end
