require 'rspec/core/bisect/utilities'

module RSpec::Core
  RSpec.describe Bisect::Notifier do
    class ExampleFormatterClass
      def foo(notification); end
    end

    let(:formatter) { instance_spy(ExampleFormatterClass) }
    let(:notifier) { Bisect::Notifier.new(formatter) }

    it 'publishes events to the wrapped formatter' do
      notifier.publish :foo, :length => 15, :width => 12

      expect(formatter).to have_received(:foo).with(an_object_having_attributes(
        :length => 15, :width => 12
      ))
    end

    it 'does not publish events the formatter does not recognize' do
      expect {
        notifier.publish :unrecognized_event, :length => 15, :width => 12
      }.not_to raise_error
    end
  end
end
