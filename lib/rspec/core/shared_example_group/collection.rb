module RSpec
  module Core
    module SharedExampleGroup
      class Collection

        def initialize sources, examples
          @sources, @examples = sources, examples
        end

        def [] key
          fetch_examples(key) || warn_deprecation_and_fetch_anyway(key)
        end

        private

          def fetch_examples key
            for source in @sources.reverse
              if @examples[source].has_key? key
                return @examples[source][key]
              end
            end
            nil
          end

          def warn_deprecation_and_fetch_anyway key
            all_examples = @examples.values.inject({},&:merge)
            example = all_examples[key]
            if example
              RSpec.warn_deprecation <<-WARNING.gsub(/^ +\|/, '')
                    Accessing shared_examples defined across contexts is deprecated.
                    Please declare shared_examples within a shared context, or at the top level
              WARNING
            end
            example
          end

      end
    end
  end
end
