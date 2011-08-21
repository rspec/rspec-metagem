require 'rr'

RSpec.configuration.backtrace_clean_patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)

module RSpec
  module Core
    module MockFrameworkAdapter

      def self.framework_name; :rr end

      include RR::Adapters::RSpec2
    end
  end
end
