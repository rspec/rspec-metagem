require 'rspec/expectations/syntax'

module RSpec
  module Matchers
    class Configuration
      def syntax=(values)
        if Array(values).include?(:expect)
          Expectations::Syntax.enable_expect
        else
          Expectations::Syntax.disable_expect
        end

        if Array(values).include?(:should)
          Expectations::Syntax.enable_should
        else
          Expectations::Syntax.disable_should
        end
      end

      def syntax
        syntaxes = []
        syntaxes << :should if Expectations::Syntax.should_enabled?
        syntaxes << :expect if Expectations::Syntax.expect_enabled?
        syntaxes
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    # set default syntax
    configuration.syntax = [:expect, :should]
  end
end

