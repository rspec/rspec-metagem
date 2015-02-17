module RSpec
  module Expectations
  end

  module Matchers
    def self.configuration; RSpec::Core::NullReporter; end
  end
end
