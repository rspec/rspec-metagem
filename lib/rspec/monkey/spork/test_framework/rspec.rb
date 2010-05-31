if defined?(Spork::TestFramework::RSpec)
  class Spork::TestFramework::RSpec < Spork::TestFramework
    def run_tests(argv, stderr, stdout)
      ::RSpec::Core::Runner.new.run(argv, stderr, stdout)
    end
  end
end
