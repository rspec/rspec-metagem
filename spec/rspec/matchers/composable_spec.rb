module RSpec
  module Matchers
    RSpec.describe Composable do
      RSpec::Matchers.define :matcher_using_surface_descriptions_in do |expected|
        match { false }
        failure_message { surface_descriptions_in(expected) }
      end

      it 'does not blow up when surfacing descriptions from an unreadable IO object' do
        expect {
          expect(3).to matcher_using_surface_descriptions_in(STDOUT)
        }.to fail_with(STDOUT.inspect)
      end
    end
  end
end
