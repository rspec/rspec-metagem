module Rspec
  module Core

    module Let

      module ClassMethods
        def let(name, &block)
          define_method(name) do
            __memoized[name] ||= instance_eval(&block)
          end
        end

        def let!(name, &block)
          let(name, &block)
          before { __send__(name) } 
        end
      end

      module InstanceMethods
        def __memoized
          @__memoized ||= {}
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
        mod.__send__ :include, InstanceMethods
      end

    end

  end
end
