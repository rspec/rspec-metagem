module RSpec
  module Core
    # @private
    module FlatMap
      if [].respond_to?(:flat_map)
        def flat_map(array)
          array.flat_map { |item| yield item }
        end
      else # for 1.8.7
        def flat_map(array)
          array.map { |item| yield item }.flatten
        end
      end

      module_function :flat_map
    end
  end
end
