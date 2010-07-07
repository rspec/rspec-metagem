module RSpec
  module Core
    module Hooks

      class HookBase
        attr_reader :options

        def initialize(options, block)
          @options = options
          @block = block
        end

        def options_apply?(group)
          !group || group.all_apply?(options)
        end

        def to_proc
          @block
        end
      end

      class Hook < HookBase
        def call
          @block.call
        end

        def run_in(example)
          example ? example.instance_eval(&self) : call
        end
      end

      class AroundHook < HookBase
        def call(wrapped_example)
          @block.call(wrapped_example)
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

      def around(scope=:each, options={}, &block)
        hooks[:around][scope] << AroundHook.new(options, block)
      end

      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example=nil, options={})
        if options[:reverse]
          hooks[hook][scope].reverse.each {|h| h.run_in(example) }
        else
          hooks[hook][scope].each {|h| h.run_in(example) }
        end
      end

      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example, options={})
        until hooks[hook][scope].empty?
          if options[:reverse] 
            hooks[hook][scope].shift.run_in(example)
          else
            hooks[hook][scope].pop.run_in(example)
          end
        end
      end

      def run_hook_filtered(hook, scope, group, example)
        find_hook(hook, scope, group).each {|h| h.run_in(example) }
      end

      def find_hook(hook, scope, group)
        hooks[hook][scope].select {|hook| hook.options_apply?(group)}
      end
    end
  end
end
