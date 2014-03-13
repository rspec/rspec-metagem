require 'spec_helper'

module RSpec
  module Core
    class Example
      RSpec.describe ExecutionResult do
        it "supports ruby 2.1's `to_h` protocol" do
          er = ExecutionResult.new
          er.status = "pending"
          er.pending_message = "just because"

          expect(er.to_h).to include(
            :status => "pending",
            :pending_message => "just because"
          )
        end

        it 'includes all defined attributes in the `to_h` hash even if not set' do
          expect(ExecutionResult.new.to_h).to include(
            :status => nil,
            :pending_message => nil
          )
        end

        it 'provides a `pending_fixed?` predicate' do
          er = ExecutionResult.new
          expect { er.pending_fixed = true }.to change(er, :pending_fixed?).to(true)
        end

        describe "backwards compatibility" do
          it 'supports indexed access like a hash' do
            er = ExecutionResult.new
            er.status = "failed"
            expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /execution_result/)
            expect(er[:status]).to eq("failed")
          end

          it 'supports indexed updates like a hash' do
            er = ExecutionResult.new
            expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /execution_result/)
            er[:status] = "passed"
            expect(er.status).to eq("passed")
          end

          it 'can get and set user defined attributes like with a hash' do
            er = ExecutionResult.new
            allow_deprecation
            expect { er[:foo] = 3 }.to change { er[:foo] }.from(nil).to(3)
            expect(er.to_h).to include(:foo => 3)
          end

          it 'supports `update` like a hash' do
            er = ExecutionResult.new
            expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /execution_result/)
            er.update(:status => "failed", :exception => ArgumentError.new)
            expect(er.status).to eq("failed")
            expect(er.exception).to be_a(ArgumentError)
          end

          it 'can set undefined attribute keys through any hash mutation method' do
            allow_deprecation
            er = ExecutionResult.new
            er.update(:status => "failed", :foo => 3)
            expect(er.to_h).to include(:status => "failed", :foo => 3)
          end

          it 'supports `merge` like a hash' do
            er = ExecutionResult.new
            er.status = "pending"
            er.pending_message = "just because"

            expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /execution_result/)
            merged = er.merge(:status => "failed", :foo => 3)

            expect(merged).to include(
              :status => "failed",
              :pending_message => "just because",
              :foo => 3
            )

            expect(er.status).to eq("pending")
          end

          it 'supports blocks for hash methods that support one' do
            er = ExecutionResult.new
            expect_deprecation_with_call_site(__FILE__, __LINE__ + 1, /execution_result/)
            expect(er.fetch(:foo) { 3 }).to eq(3)
          end

          # It's IndexError on 1.8.7, KeyError on 1.9+
          fetch_not_found_error_class = defined?(::KeyError) ? ::KeyError : ::IndexError

          specify '#fetch treats unset properties the same as a hash does' do
            allow_deprecation
            er = ExecutionResult.new
            expect { er.fetch(:status) }.to raise_error(fetch_not_found_error_class)
            er.status = "foo"
            expect(er.fetch(:status)).to eq("foo")
          end
        end
      end
    end
  end
end
