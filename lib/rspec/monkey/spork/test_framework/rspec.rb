if defined?(Spork::TestFramework::RSpec)
  class Spork::TestFramework::RSpec < Spork::TestFramework
    def run_tests(argv, err, out)
      ::RSpec::Core::Runner.new.run(argv, err, out)
    end
  end
end
