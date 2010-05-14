module Rspec
  module Core
    class Configuration
      def mock_with(use_me_to_mock)
        self.mock_framework = use_me_to_mock
      end
    end
  end
end

module ConstMissing
  def const_missing(name)
    if :Spec == name
      Rspec.warn <<-WARNING
*****************************************************************
DEPRECATION WARNING: you are using a deprecated constant that will
be removed from a future version of Rspec.

* Spec is deprecated.
* Rspec is the new top-level module in Rspec-2

#{caller(0)[1]}
*****************************************************************
WARNING
      Rspec
    else
      super(name)
    end
  end
end

Object.extend(ConstMissing)
