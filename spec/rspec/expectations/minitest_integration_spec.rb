require 'spec_helper'

module RSpec
  describe Matchers do

    let(:sample_matchers) do
      [:be,
       :be_instance_of,
       :be_kind_of]
    end

    context "once required" do
      include MinitestIntegration

      it "includes itself in Minitest::Test" do
        with_minitest_loaded do
          minitest_case = MiniTest::Test.allocate
          sample_matchers.each do |sample_matcher|
              expect(minitest_case).to respond_to(sample_matcher)
          end
        end
      end

    end

  end
end
