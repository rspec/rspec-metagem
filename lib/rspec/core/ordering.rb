module RSpec
  module Core
    module Ordering
      class Identity
        def order(items)
          items
        end

        def built_in?
          true
        end
      end

      class Random
        def initialize(configuration)
          @configuration = configuration
        end

        def order(items)
          Kernel.srand @configuration.seed
          ordering = items.shuffle
          Kernel.srand # reset random generation
          ordering
        end

        def built_in?
          true
        end
      end

      class Custom
        def initialize(callable)
          @callable = callable
        end

        def order(list)
          @callable.call(list)
        end

        def built_in?
          false
        end
      end

      class Registry
        attr_reader :global_ordering

        def initialize(configuration)
          @configuration = configuration
          @strategies = {}

          register(:random,   Random.new(configuration))
          register(:default,  Identity.new)

          set_global_order(:default)
        end

        def [](callable_or_sym)
          if callable_or_sym.respond_to?(:call)
            Custom.new(callable_or_sym)
          elsif callable_or_sym.nil?
            @global_ordering
          else
            @strategies[callable_or_sym.to_sym] || @global_ordering
          end
        end

        def register(sym, klass)
          @strategies[sym] = klass
        end

        def set_global_order(name = nil, &block)
          if block_given?
            @global_ordering = Custom.new(block)
          else
            @global_ordering = @strategies.fetch(name)
          end
        end
      end
    end
  end
end

