module RSpec
  module Core
    module Hooks
      def before(scope=:each, options={}, &block)
        hooks[:before][scope] << [options, block]
      end

      def after(scope=:each, options={}, &block)
        hooks[:after][scope] << [options, block]
      end

      def before_eachs
        hooks[:before][:each]
      end

      def before_alls
        hooks[:before][:all]
      end

      def after_eachs
        hooks[:after][:each]
      end

      def after_alls
        hooks[:after][:all]
      end

      def around_eachs
        hooks[:around][:each]
      end

      def around(scope=:each, &block)
        RSpec::deprecate("around", "before and after")
        hooks[:around][scope] << block
      end

      def hooks
        @hooks ||= { 
          :around => { :each => [] },
          :before => { :each => [], :all => [], :suite => [] }, 
          :after => { :each => [], :all => [], :suite => [] } 
        }
      end

      def run_hook(hook, scope, group=nil, example=nil)
        find_hook(hook, scope, group).each do |blk| 
          example ? example.instance_eval(&blk) : blk.call
        end
      end

      def find_hook(hook, scope, group)
        hooks[hook][scope].select do |filters, block|
          !group || group.all_apply?(filters)
        end.map { |filters, block| block }
      end
    end
  end
end
