module RSpec
  module Matchers
    describe Composable do
      def reload_composable_module
        RSpec::Matchers.send(:remove_const, :Composable)
        load "rspec/matchers/composable.rb"
      end

      it 'works properly when loaded after YARD has been loaded' do
        with_isolated_stderr do
          stub_const("YARD", Module.new)
          reload_composable_module

          expect {
            expect("a" => 1).to eq("a" => 2)
          }.to fail_matching('expected: {"a"=>2}')
        end
      end
    end
  end
end
