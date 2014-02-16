require 'rspec/support/spec/in_sub_process'

module MathnIntegrationSupport
  include RSpec::Support::InSubProcess

  def with_mathn_loaded
    in_sub_process do
      require 'mathn'
      yield
    end
  end
end
