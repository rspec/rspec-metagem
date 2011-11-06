module RSpec
  module Core
    module SharedContext
      include Hooks
      include Let::ClassMethods

      def included(group)
        [:before, :after].each do |type|
          [:all, :each].each do |scope|
            group.hooks[type][scope].concat hooks[type][scope]
          end
        end
        _nested_group_declarations.each do |name, block, *args|
          group.describe name, *args, &block
        end
      end

      def describe(name, *args, &block)
        _nested_group_declarations << [name, block, *args]
      end

      alias_method :context, :describe

      private

      def _nested_group_declarations
        @_nested_group_declarations ||= []
      end
    end
  end

  SharedContext = Core::SharedContext
end
