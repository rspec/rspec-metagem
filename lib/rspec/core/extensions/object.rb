module RSpec
  module Core
    module ObjectExtensions
      def describe(*args, &example_group_block)
        args << {} unless args.last.is_a?(Hash)
        args.last.update :caller => caller(1)
        RSpec::Core::ExampleGroup.describe(*args, &example_group_block)
      end
    end
  end
end

class Object
  include RSpec::Core::ObjectExtensions
end
