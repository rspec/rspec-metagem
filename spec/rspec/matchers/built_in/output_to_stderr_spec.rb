require 'spec_helper'

module RSpec
  module Matchers
    describe "output_to_stderr matcher" do
      include_examples "output_to_stream", :stderr do
        let(:stream) { $stderr }
      end
    end
  end
end
