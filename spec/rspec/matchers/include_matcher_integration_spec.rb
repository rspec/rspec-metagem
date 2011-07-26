require 'spec_helper'

module RSpec
  module Matchers
    describe "include() interaction with built-in matchers" do
      it "works with be_within(delta).of(expected)" do
        [10, 20, 30].should include( be_within(5).of(24) )
        [10, 20, 30].should_not include( be_within(3).of(24) )
      end
      
      it "works with be_instance_of(klass)" do
        ["foo", 123, {:foo => "bar"}].should include( be_instance_of(Hash) )
        ["foo", 123, {:foo => "bar"}].should_not include( be_instance_of(Range) )
      end
      
      it "works with be_kind_of(klass)" do
        class StringSubclass < String; end
        class NotHashSubclass; end
        
        [StringSubclass.new("baz")].should include( be_kind_of(String) )
        [NotHashSubclass.new].should_not include( be_kind_of(Hash) )
      end
      
      it "works with be_[some predicate]" do
        [stub("actual", :happy? => true)].should include( be_happy )
        [stub("actual", :happy? => false)].should_not include( be_happy )
      end
    end
  end
end
