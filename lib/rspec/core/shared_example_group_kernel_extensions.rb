module Rspec
  module Core
    module SharedExampleGroupKernelExtensions

      def share_examples_for(name, &block)
        Rspec::Core.world.shared_example_groups[name] = block
      end

      def share_as(name, &block)
        if Object.const_defined?(name)
          puts "name was defined as #{name.inspect}"
          raise NameError, "The first argument (#{name}) to share_as must be a legal name for a constant not already in use."
        end
        
        mod = Module.new do
          @shared_block = block

          def self.included(kls)
            kls.module_eval(&@shared_block)
          end
        end

        shared_const = Object.const_set(name, mod)
        Rspec::Core.world.shared_example_groups[shared_const] = block
      end

      alias :shared_examples_for :share_examples_for

    end
  end
end
