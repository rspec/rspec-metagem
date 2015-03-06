require 'rspec/core/example_status_persister'

module RSpec::Core
  RSpec.describe "Example status merging" do
    let(:existing_spec_file) { Metadata.relative_path(__FILE__) }

    context "when no examples from this or previous runs are given" do
      it "returns an empty array" do
        merged = merge(:this_run => [], :from_previous_runs => [])
        expect(merged).to eq([])
      end
    end

    context "when there are no examples from previous runs" do
      it "returns the examples from this run" do
        this_run = [
          example(existing_spec_file, "1:1", "passed"),
          example(existing_spec_file, "1:2", "failed")
        ]

        merged = merge(:this_run => this_run, :from_previous_runs => [])
        expect(merged).to match_array(this_run)
      end
    end

    context "when there are no examples from this run" do
      it "returns the examples from the previous runs" do
        from_previous_runs = [
          example(existing_spec_file, "1:1", "passed"),
          example(existing_spec_file, "1:2", "failed")
        ]

        merged = merge(:this_run => [], :from_previous_runs => from_previous_runs)
        expect(merged).to match_array(from_previous_runs)
      end
    end

    context "for examples that are only in the set for this run" do
      it "takes them indiscriminately, even if they did not execute" do
        this_run = [ example(existing_spec_file, "1:1", ExampleStatusMerger::UNKNOWN_STATUS) ]

        merged = merge(:this_run => this_run, :from_previous_runs => [])
        expect(merged).to match_array(this_run)
      end
    end

    context "for examples that are only in the set for previous runs" do
      context "if there are other examples from this run for the same file " do
        it "deletes them since the examples must no longer exist" do
          this_run           = [ example(existing_spec_file, "1:1", "passed") ]
          from_previous_runs = [ example(existing_spec_file, "1:2", "failed") ]

          merged = merge(:this_run => this_run, :from_previous_runs => from_previous_runs)
          expect(merged).to match_array(this_run)
        end
      end

      context "if there are no other examples from this run for the same file" do
        it "deletes them if the file no longer exist" do
          from_previous_runs = [ example("./some/deleted_path/foo_spec.rb", "1:2", "failed") ]

          merged = merge(:this_run => [], :from_previous_runs => from_previous_runs)
          expect(merged).to eq([])
        end

        it "keeps them if the file exists because the examples may still exist" do
          from_previous_runs = [ example(existing_spec_file, "1:2", "failed") ]

          merged = merge(:this_run => [], :from_previous_runs => from_previous_runs)
          expect(merged).to eq(from_previous_runs)
        end
      end
    end

    context "for examples that are in both sets" do
      it "takes the status from this run as long as the example executed" do
        this_run           = [ example("foo_spec.rb", "1:1", "passed") ]
        from_previous_runs = [ example("foo_spec.rb", "1:1", "failed") ]

        merged = merge(:this_run => this_run, :from_previous_runs => from_previous_runs)
        expect(merged).to match_array(this_run)
      end

      it "takes the status from previous runs if the example was loaded but did not execute" do
        this_run           = [ example("foo_spec.rb", "1:1", ExampleStatusMerger::UNKNOWN_STATUS) ]
        from_previous_runs = [ example("foo_spec.rb", "1:1", "failed") ]

        merged = merge(:this_run => this_run, :from_previous_runs => from_previous_runs)
        expect(merged).to match_array(from_previous_runs)
      end
    end

    it 'sorts the returned examples to make the saved file more easily scannable' do
      this_run = [
        ex_c_1_1  = example("c_spec.rb", "1:1",  "passed"),
        ex_a_1_2  = example("a_spec.rb", "1:2",  "failed"),
        ex_a_1_10 = example("a_spec.rb", "1:10", "failed"),
        ex_a_1_9  = example("a_spec.rb", "1:9",  "failed"),
      ]

      merged = merge(:this_run => this_run, :from_previous_runs => [])
      expect(merged).to eq([ ex_a_1_2, ex_a_1_9, ex_a_1_10, ex_c_1_1 ])
    end

    it "preserves any extra attributes include in the example hashes" do
      this_run = [
        example(existing_spec_file, "1:1", "passed", :foo => 23),
        example(existing_spec_file, "1:2", "failed", :bar => 12)
      ]

      from_previous_runs = [
        example(existing_spec_file, "1:1", "passed", :foo => -23),
        example(existing_spec_file, "1:2", "failed", :bar => -12)
      ]

      merged = merge(:this_run => this_run, :from_previous_runs => from_previous_runs)
      expect(merged).to contain_exactly(
        a_hash_including(:foo => 23),
        a_hash_including(:bar => 12)
      )
    end

    def example(file, scoped_id, status, extras = {})
      { :example_id => "#{file}[#{scoped_id}]", :status => status }.merge(extras)
    end

    def merge(options)
      ExampleStatusMerger.merge(
        options.fetch(:this_run),
        options.fetch(:from_previous_runs)
      )
    end
  end

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
