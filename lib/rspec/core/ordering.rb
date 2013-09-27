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
        def initialize(configuration)
          @configuration = configuration
          @strategies    = {}

          register(:random,  Random.new(configuration))

          # TODO: resolve this duplication.
          register(:default, Identity.new)
          register(:global,  Identity.new)
        end

        def fetch(name, &fallback)
          @strategies.fetch(name, &fallback)
        end

        def register(sym, strategy)
          @strategies[sym] = strategy
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
          ordering = if block
                       Custom.new(block)
                     else
                       @example_ordering_registry.fetch(ordering)
                     end

          @example_ordering_registry.register(:global, ordering)
        end

        def order_groups(ordering=nil, &block)
          return if @order_forced
          ordering = if block
                       Custom.new(block)
                     else
                       @group_ordering_registry.fetch(ordering)
                     end

          @group_ordering_registry.register(:global, ordering)
        end

        def order_groups_and_examples(ordering=nil, &block)
          order_groups(ordering, &block)
          order_examples(ordering, &block)
        end

        def register_group_ordering(name, strategy = Custom.new(Proc.new { |list| yield list }))
          @group_ordering_registry.register(name, strategy)
        end

        def register_example_ordering(name, strategy = Custom.new(Proc.new { |list| yield list }))
          @example_ordering_registry.register(name, strategy)
        end

        def register_group_and_example_ordering(name, strategy = Custom.new(Proc.new { |list| yield list }))
          register_group_ordering(name, strategy)
          register_example_ordering(name, strategy)
        end
      end
    end
  end
end

