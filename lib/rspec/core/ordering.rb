module RSpec
  module Core
    # @private
    module Ordering
      # @private
      # The default ordering (defined order).
      class Identity
        def order(items)
          items
        end
      end

      # @private
      # Orders items randomly.
      class Random
        def initialize(configuration)
          @configuration = configuration
          @used = false
        end

        def used?
          @used
        end

        def order(items)
          @used = true
          Kernel.srand @configuration.seed
          ordering = items.shuffle
          Kernel.srand # reset random generation
          ordering
        end
      end

      # @private
      # Orders items based on a custom block.
      class Custom
        def initialize(callable)
          @callable = callable
        end

        def order(list)
          @callable.call(list)
        end
      end

      # @private
      # Stores the different ordering strategies.
      class Registry
        attr_reader :global_ordering

        def initialize(configuration)
          @configuration = configuration
          @strategies    = {}

          register(:random,  Random.new(configuration))
          register(:default, Identity.new)

          set_global_order(:default)
        end

        def fetch(callable_or_sym, &fallback)
          if callable_or_sym.respond_to?(:call)
            Custom.new(callable_or_sym)
          elsif callable_or_sym.nil?
            @global_ordering
          else
            @strategies.fetch(callable_or_sym.to_sym, &fallback)
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

        def used_random_seed?
          @strategies[:random].used?
        end
      end

      # @private
      # Manages ordering configuration.
      #
      # @note This is not intended to be used externally. Use
      #       the APIs provided by `RSpec::Core::Configuration` instead.
      class ConfigurationManager
        attr_reader :seed, :group_ordering_registry, :example_ordering_registry

        def initialize
          @group_ordering_registry   = Registry.new(self)
          @example_ordering_registry = Registry.new(self)
          @seed = srand % 0xFFFF
          @seed_forced = false
          @order_forced = false
        end

        def seed_used?
          @example_ordering_registry.used_random_seed? ||
          @group_ordering_registry.used_random_seed?
        end

        def seed=(seed)
          return if @seed_forced
          order_groups_and_examples(:random)
          @seed = seed.to_i
        end

        def order=(type)
          order, seed = type.to_s.split(':')
          @seed = seed = seed.to_i if seed

          ordering_name = if order.include?('rand')
            :random
          elsif order == 'default'
            :default
          end

          order_groups_and_examples(ordering_name) if ordering_name
        end

        def force(hash)
          if hash.has_key?(:seed)
            self.seed = hash[:seed]
            @seed_forced  = true
            @order_forced = true
          elsif hash.has_key?(:order)
            self.order = hash[:order]
            @order_forced = true
          end
        end

        def order_examples(ordering=nil, &block)
          return if @order_forced
          @example_ordering_registry.set_global_order(ordering, &block)
        end

        def order_groups(ordering=nil, &block)
          return if @order_forced
          @group_ordering_registry.set_global_order(ordering, &block)
        end

        def order_groups_and_examples(ordering=nil, &block)
          order_groups(ordering, &block)
          order_examples(ordering, &block)
        end

        def register_group_ordering(name, &block)
          @group_ordering_registry.register(name, Custom.new(block))
        end

        def register_example_ordering(name, &block)
          @example_ordering_registry.register(name, Custom.new(block))
        end

        def register_group_and_example_ordering(name, &block)
          register_group_ordering(name, &block)
          register_example_ordering(name, &block)
        end
      end
    end
  end
end

