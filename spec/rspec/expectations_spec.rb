require 'spec_helper'

module RSpec
  describe Expectations do
    it 'does not allow expectation failures to be caught by a bare rescue' do
      expect {
        expect(2).to eq(3) rescue nil
      }.to fail_matching("expected: 3")
    end
  end
end

