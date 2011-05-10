module RSpec
  module Core
    module Applicable
      def apply_to?(target)
        target.apply?
      end
    end
  end
end
