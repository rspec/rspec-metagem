module RSpec
  module Core
    class Configuration
      def mock_with(use_me_to_mock)
        self.mock_framework = use_me_to_mock
      end
    end

    module ConstMissing
      def const_missing(name)
        if :Spec == name
          RSpec.warn <<-WARNING
*****************************************************************
DEPRECATION WARNING: you are using a deprecated constant that will
be removed from a future version of RSpec.

* Spec is deprecated.
* RSpec is the new top-level module in RSpec-2

#{caller(0)[1]}
*****************************************************************
WARNING
          RSpec
        else
          super(name)
        end
      end
    end

  end

end

Object.extend(RSpec::Core::ConstMissing)
