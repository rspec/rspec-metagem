module RSpec
  module Core
    class OrderingRegistry
      def initialize(configuration)
        @configuration = configuration
        @strategies = {}

        register(:random,   Ordering::RandomOrdering.new)
        register(:default,  Ordering::IdentityOrdering.new)

        set_global_example_order(:default)
        set_global_group_order(:default)
      end

      def resolve_example_ordering(callable_or_sym = nil)
        if callable_or_sym.respond_to?(:call)
          Ordering::CustomOrdering.new(callable_or_sym)
        elsif callable_or_sym.nil?
          @global_example_ordering
        else
          @strategies[callable_or_sym.to_sym] || @global_example_ordering
        end
      end

      def resolve_group_ordering(callable_or_sym = nil)
        if callable_or_sym.respond_to?(:call)
          Ordering::CustomOrdering.new(callable_or_sym)
        elsif callable_or_sym.nil?
          @global_group_ordering
        else
          @strategies[callable_or_sym.to_sym] || @global_group_ordering
        end
      end

      def register(sym, klass)
        @strategies[sym] = klass
      end

      def set_global_example_order(name = nil, &block)
        if block_given?
          @global_example_ordering = Ordering::CustomOrdering.new(block)
        else
          @global_example_ordering = @strategies.fetch(name)
        end
      end

      def set_global_group_order(name = nil, &block)
        if block_given?
          @global_group_ordering = Ordering::CustomOrdering.new(block)
        else
          @global_group_ordering = @strategies.fetch(name)
        end
      end
    end
  end
end
