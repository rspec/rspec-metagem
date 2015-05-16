RSpec.describe "Using `:aggregate_failures` metadata" do
  it 'applies `aggregate_failures` to examples or groups tagged with `:aggregate_failures`' do
    ex = nil

    RSpec.describe "Aggregate failures", :aggregate_failures do
      ex = it "has multiple failures" do
        expect(1).to be_even
        expect(2).to be_odd
      end
    end.run

    expect(ex.execution_result.exception).to have_attributes(
      :failures => [
        an_object_having_attributes(:message => 'expected `1.even?` to return true, got false'),
        an_object_having_attributes(:message => 'expected `2.odd?` to return true, got false')
      ]
    )
  end

  it 'does not interfere with other `around` hooks' do
    events = []

    RSpec.describe "Outer" do
      around do |ex|
        events << :outer_before
        ex.run
        events << :outer_after
      end

      context "aggregating failures", :aggregate_failures do
        context "inner" do
          around do |ex|
            events << :inner_before
            ex.run
            events << :inner_after
          end

          it "has multiple failures" do
            events << :example_before
            expect(1).to be_even
            expect(2).to be_odd
            events << :example_after
          end
        end
      end
    end.run

    expect(events).to eq([:outer_before, :inner_before, :example_before,
                          :example_after, :inner_after, :outer_after])
  end
end
