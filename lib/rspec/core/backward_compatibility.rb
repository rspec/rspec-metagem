module RSpec
  module Core
    module ConstMissing
      def const_missing(name)
        case name
        when :Rspec, :Spec
          RSpec.warn_deprecation <<-WARNING
*****************************************************************
DEPRECATION WARNING: you are using a deprecated constant that will
be removed from a future version of RSpec.

* #{name} is deprecated.
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
