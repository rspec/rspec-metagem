require 'rspec/core/example_status_persister'

module RSpec::Core
  RSpec.describe "Example status serialization" do
    it 'serializes the provided example statuses in a human readable format' do
      examples = [
        { :example_id => "./spec/unit/foo_spec.rb[1:1]",        :status => 'passed'  },
        { :example_id => "./spec/unit/foo_spec.rb[1:2]",        :status => 'pending' },
        { :example_id => "./spec/integration/foo_spec.rb[1:2]", :status => 'failed'  }
      ]

      produce_expected_output = eq(unindent(<<-EOS))
        example_id                          | status  |
        ----------------------------------- | ------- |
        ./spec/unit/foo_spec.rb[1:1]        | passed  |
        ./spec/unit/foo_spec.rb[1:2]        | pending |
        ./spec/integration/foo_spec.rb[1:2] | failed  |
      EOS

      if RUBY_VERSION == '1.8.7' # unordered hashes :(.
        produce_expected_output |= eq(unindent(<<-EOS))
          status  | example_id                          |
          ------- | ----------------------------------- |
          passed  | ./spec/unit/foo_spec.rb[1:1]        |
          pending | ./spec/unit/foo_spec.rb[1:2]        |
          failed  | ./spec/integration/foo_spec.rb[1:2] |
        EOS
      end

      expect(dump(examples)).to produce_expected_output
    end

    it 'takes the column headers into account when sizing the columns' do
      examples = [
        { :long_key => '12',  :a => '20' },
        { :long_key => '120', :a => '2'  }
      ]

      produce_expected_output = eq(unindent(<<-EOS))
        long_key | a  |
        -------- | -- |
        12       | 20 |
        120      | 2  |
      EOS

      if RUBY_VERSION == '1.8.7' # unordered hashes :(.
        produce_expected_output |= eq(unindent(<<-EOS))
           a  | long_key |
           -- | -------- |
           20 | 12       |
           2  | 120      |
        EOS
      end

      expect(dump(examples)).to produce_expected_output
    end

    it 'can round trip through the dumper and parser' do
      examples = [
        { :example_id => "./spec/unit/foo_spec.rb[1:1]",        :status => 'passed'  },
        { :example_id => "./spec/unit/foo_spec.rb[1:2]",        :status => 'pending' },
        { :example_id => "./spec/integration/foo_spec.rb[1:2]", :status => 'failed'  }
      ]

      round_tripped = parse(dump(examples))
      expect(round_tripped).to eq(examples)
    end

    it 'produces nothing when given nothing' do
      expect(dump([])).to eq(nil)
    end

    # Intended for use with indented heredocs.
    # taken from Ruby Tapas:
    # https://rubytapas.dpdcart.com/subscriber/post?id=616#files
    def unindent(s)
      s.gsub(/^#{s.scan(/^[ \t]+(?=\S)/).min}/, "")
    end

    def dump(examples)
      ExampleStatusDumper.dump(examples)
    end

    def parse(string)
      ExampleStatusParser.parse(string)
    end
  end
end
