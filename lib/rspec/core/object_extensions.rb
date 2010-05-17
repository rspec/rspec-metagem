module RSpec
  module Core
    module ObjectExtensions
      def describe(*args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update :caller => caller(1)
        RSpec::Core::ExampleGroup.describe(*args, &example_group_block)
      end

      alias :context :describe
    end
  end
end

include RSpec::Core::ObjectExtensions
