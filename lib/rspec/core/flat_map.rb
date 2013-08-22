module RSpec
  module Core
    module FlatMap
      if [].respond_to?(:flat_map)
        def flat_map(array)
          array.flat_map { |item| yield item }
        end
      else
        def flat_map(array)
          array.map { |item| yield item }.flatten
        end
      end

      module_function :flat_map
    end
  end
end
