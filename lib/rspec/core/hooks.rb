module RSpec
  module Core
    module Hooks
      def hooks
        @hooks ||= { 
          :around => { :each => [] },
          :before => { :each => [], :all => [], :suite => [] }, 
          :after => { :each => [], :all => [], :suite => [] } 
        }
      end

      def before(scope=:each, options={}, &block)
        hooks[:before][scope] << [options, block]
      end

      def after(scope=:each, options={}, &block)
        hooks[:after][scope] << [options, block]
      end

      def around(scope=:each, &block)
        RSpec::deprecate("around", "before and after")
        hooks[:around][scope] << block
      end

      def run_hook(hook, scope, example=nil, options={})
        if options[:reverse]
          hooks[hook][scope].reverse.each &run_hook_in(example)
        else
          hooks[hook][scope].each &run_hook_in(example)
        end
      end

      def run_hook!(hook, scope, example, options={})
        until hooks[hook][scope].empty?
          if options[:reverse] 
            example.instance_eval &hooks[hook][scope].shift.last
          else
            example.instance_eval &hooks[hook][scope].pop.last
          end
        end
      end

      def run_hook_filtered(hook, scope, group, example)
        find_hook(hook, scope, group).each &run_hook_in(example)
      end

      def find_hook(hook, scope, group)
        hooks[hook][scope].select do |filters, block|
          !group || group.all_apply?(filters)
        end
      end

    private

      def run_hook_in(example)
        lambda {|arr| example ? example.instance_eval(&arr.last) : arr.last.call}
      end
    end
  end
end
