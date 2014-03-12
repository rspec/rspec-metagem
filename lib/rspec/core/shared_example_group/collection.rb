module RSpec
  module Core
    module SharedExampleGroup
      # @private
      class Collection

        def initialize(sources, examples)
          @sources, @examples = sources, examples
        end

        # @private
        def [](key)
          fetch_examples(key)
        end

        private

          def fetch_examples(key)
            @examples[source_for key][key]
          end

          def source_for(key)
            @sources.reverse.find { |source| @examples[source].has_key? key }
          end

      end
    end
  end
end
