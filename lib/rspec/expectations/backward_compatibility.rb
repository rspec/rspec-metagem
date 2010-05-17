# Cucumber 0.7 includes Rspec::Expectations
module RSpec
  module Expectations
    module ConstMissing
      def const_missing(name)
        name == :Rspec ? RSpec : super(name)
      end
    end
  end
end

Object.extend(RSpec::Expectations::ConstMissing)
