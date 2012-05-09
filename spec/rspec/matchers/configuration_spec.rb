require 'spec_helper'

module RSpec
  module Matchers
    describe ".configuration" do
      it 'returns a memoized configuration instance' do
        RSpec::Matchers.configuration.should be_a(RSpec::Matchers::Configuration)
        RSpec::Matchers.configuration.should be(RSpec::Matchers.configuration)
      end
    end

    shared_examples_for "configuring the expectation syntax" do
      include InSubProcess

      it 'is configured to :should and :expect by default' do
        configured_syntax.should eq([:should, :expect])

        3.should eq(3)
        3.should_not eq(4)
        expect(3).to eq(3)
      end

      it 'can limit the syntax to :should' do
        in_sub_process do
          configure_syntax :should
          configured_syntax.should eq([:should])

          3.should eq(3)
          3.should_not eq(4)
          lambda { expect(6).to eq(6) }.should raise_error(NameError)
        end
      end

      it 'does not raise an error if configured to :should twice' do
        in_sub_process do
          configure_syntax :should
          configure_syntax :should
        end
      end

      it 'can limit the syntax to :expect' do
        in_sub_process do
          configure_syntax :expect
          expect(configured_syntax).to eq([:expect])

          expect(3).to eq(3)
          expect { 3.should eq(3) }.to raise_error(NameError)
          expect { 3.should_not eq(3) }.to raise_error(NameError)
        end
      end

      it 'does not raise an error if configured to :expect twice' do
        in_sub_process do
          configure_syntax :expect
          configure_syntax :expect
        end
      end

      it 'can re-enable the :should syntax' do
        in_sub_process do
          configure_syntax :expect
          configure_syntax [:should, :expect]
          configured_syntax.should eq([:should, :expect])

          3.should eq(3)
          3.should_not eq(4)
          expect(3).to eq(3)
        end
      end

      it 'can re-enable the :expect syntax' do
        in_sub_process do
          configure_syntax :should
          configure_syntax [:should, :expect]
          configured_syntax.should eq([:should, :expect])

          3.should eq(3)
          3.should_not eq(4)
          expect(3).to eq(3)
        end
      end
    end

    describe "configuring rspec-expectations directly" do
      it_behaves_like "configuring the expectation syntax" do
        def configure_syntax(syntax)
          RSpec::Matchers.configuration.syntax = syntax
        end

        def configured_syntax
          RSpec::Matchers.configuration.syntax
        end
      end
    end

    describe "configuring using the rspec-core config API" do
      it_behaves_like "configuring the expectation syntax" do
        def configure_syntax(syntax)
          RSpec.configure do |rspec|
            rspec.expect_with :rspec do |c|
              c.syntax = syntax
            end
          end
        end

        def configured_syntax
          RSpec.configure do |rspec|
            rspec.expect_with :rspec do |c|
              return c.syntax
            end
          end
        end
      end
    end

  end
end

