module RSpec
  module Core
    module Bisect
      # @private
      ExampleSetDescriptor = Struct.new(:all_example_ids, :failed_example_ids)

      # @private
      class BisectFailedError < StandardError
        def self.for_failed_spec_run(spec_output)
          new("Failed to get results from the spec run. Spec run output:\n\n" +
              spec_output)
        end
      end
    end
  end
end
