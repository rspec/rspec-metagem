module RSpec
  module Core
    module Bisect
      # @private
      ExampleSetDescriptor = Struct.new(:all_example_ids, :failed_example_ids)
    end
  end
end
