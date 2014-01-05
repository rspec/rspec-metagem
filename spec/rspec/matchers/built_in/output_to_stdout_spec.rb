require 'spec_helper'

module RSpec
  module Matchers
    describe "output_to_stdout matcher" do
      include_examples "output_to_stream", :stdout do
        let(:stream) { $stdout }
      end
    end
  end
end
