module Rspec
  module Core
    module SharedBehaviour
      
      def share_examples_for(name, &block)
        ensure_shared_example_group_name_not_taken(name)
        Rspec::Core.world.shared_behaviours[name] = block
      end

      def share_as(name, &block)
        if Object.const_defined?(name)
          raise NameError, "The first argument (#{name}) to share_as must be a legal name for a constant not already in use."
        end
        
        mod = Module.new do
          @shared_block = block

          def self.included(kls)
            kls.module_eval(&@shared_block)
          end
        end

        shared_const = Object.const_set(name, mod)
        Rspec::Core.world.shared_behaviours[shared_const] = block
      end

      alias :shared_examples_for :share_examples_for

      private

      def ensure_shared_example_group_name_not_taken(name)
        if Rspec::Core.world.shared_behaviours.has_key?(name)
          raise ArgumentError.new("Shared example group '#{name}' already exists")
        end
      end

    end
  end
end

include Rspec::Core::SharedBehaviour
