require 'spec_helper'

describe "a matcher defined using the matcher DSL" do
  def question?
    :answer
  end

  it "has access to methods available in the scope of the example" do
    RSpec::Matchers::define(:ignore) {}
    ignore.question?.should eq(:answer)
  end

  it "raises when method is missing from local scope as well as matcher" do
    RSpec::Matchers::define(:ignore) {}
    expect { ignore.i_dont_exist }.to raise_error(NameError)
  end

  describe "#respond_to?" do
    it "returns true for methods in example scope" do
      RSpec::Matchers::define(:ignore) {}
      ignore.should respond_to(:question?)
    end

    it "returns false for methods not defined in matcher or example scope" do
      RSpec::Matchers::define(:ignore) {}
      ignore.should_not respond_to(:i_dont_exist)
    end
  end
end
