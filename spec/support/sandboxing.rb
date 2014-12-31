require 'rspec/core/sandbox'
require 'rspec/mocks'

# Because testing RSpec with RSpec tries to modify the same global
# objects, we sandbox every test.
RSpec.configure do |c|
  c.around do |ex|

    RSpec::Core::Sandbox.sandboxed do |config|
      config.expose_dsl_globally = false

      # If there is an example-within-an-example, we want to make sure the inner example
      # does not get a reference to the outer example (the real spec) if it calls
      # something like `pending`
      config.before(:context) { RSpec.current_example = nil }
      begin
        orig_load_path = $LOAD_PATH.dup
        RSpec::Mocks.with_temporary_scope { ex.run }
      ensure
        $LOAD_PATH.replace(orig_load_path)
      end
    end

  end
end
