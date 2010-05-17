module RSpec
  module Core
    module Hooks
      def before_blocks
        @before_blocks ||= { :all => [], :each => [] }
      end

      def after_blocks
        @after_blocks  ||= { :all => [], :each => [] }
      end

      def around_blocks
        @around_blocks ||= { :each => [] }
      end

      def before_eachs
        before_blocks[:each]
      end

      def before_alls
        before_blocks[:all]
      end

      def before(type=:each, &block)
        before_blocks[type] << block
      end

      def after_eachs
        after_blocks[:each]
      end

      def after_alls
        after_blocks[:all]
      end

      def after(type=:each, &block)
        after_blocks[type] << block
      end

      def around_eachs
        around_blocks[:each]
      end

      def around(type=:each, &block)
        around_blocks[type] << block
      end
    end
  end
end
