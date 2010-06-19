module RSpec
  module Core
    module Hooks
      class Hook
        attr_reader :options

        def initialize(options, block)
          @options = options
          @block = block
        end

        def options_apply?(group)
          !group || group.all_apply?(options)
        end

        def call
          @block.call
        end

        def to_proc
          @block
        end
      end

      def hooks
        @hooks ||= { 
          :around => { :each => [] },
          :before => { :each => [], :all => [], :suite => [] }, 
          :after => { :each => [], :all => [], :suite => [] } 
        }
      end

      def before(scope=:each, options={}, &block)
        hooks[:before][scope] << Hook.new(options, block)
      end

      def after(scope=:each, options={}, &block)
        hooks[:after][scope] << Hook.new(options, block)
      end

      def around(scope=:each, &block)
        RSpec::deprecate("around", "before and after")
        hooks[:around][scope] << block
      end

      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example=nil, options={})
        if options[:reverse]
          hooks[hook][scope].reverse.each &run_hook_in(example)
        else
          hooks[hook][scope].each &run_hook_in(example)
        end
      end

      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example, options={})
        until hooks[hook][scope].empty?
          if options[:reverse] 
            example.instance_eval &hooks[hook][scope].shift
          else
            example.instance_eval &hooks[hook][scope].pop
          end
        end
      end

      def run_hook_filtered(hook, scope, group, example)
        find_hook(hook, scope, group).each &run_hook_in(example)
      end

      def find_hook(hook, scope, group)
        hooks[hook][scope].select {|hook| hook.options_apply?(group)}
      end

    private

      def run_hook_in(example)
        lambda {|hook| example ? example.instance_eval(&hook) : hook.call}
      end
    end
  end
end
