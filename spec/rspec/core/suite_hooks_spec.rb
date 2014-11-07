require "spec_helper"
require "support/runner_support"

module RSpec::Core
  RSpec.describe "Configuration :suite hooks" do
    [:before, :after, :prepend_before, :append_before, :prepend_after, :append_after].each do |type|
      describe "a(n) #{type} hook" do
        it 'is skipped when in dry run mode' do
          RSpec.configuration.dry_run = true

          expect { |b|
            RSpec.configuration.__send__(type, :suite, &b)
            RSpec.configuration.with_suite_hooks { }
          }.not_to yield_control
        end

        it 'allows errors in the hook to propagate to the user' do
          RSpec.configuration.__send__(type, :suite) { 1 / 0 }

          expect {
            RSpec.configuration.with_suite_hooks { }
          }.to raise_error(ZeroDivisionError)
        end
      end
    end

    it 'always runs `after(:suite)` hooks even in the face of errors' do
      expect { |b|
        RSpec.configuration.after(:suite, &b)
        RSpec.configuration.with_suite_hooks { raise "boom" }
      }.to raise_error("boom").and yield_control
    end

    describe "the runner" do
      include_context "Runner support"

      it "runs :suite hooks before and after example groups in the correct order" do
        sequence = []

        config.before(:suite)         { sequence << :before_suite_2 }
        config.before(:suite)         { sequence << :before_suite_3 }
        config.append_before(:suite)  { sequence << :before_suite_4 }
        config.prepend_before(:suite) { sequence << :before_suite_1 }
        config.after(:suite)          { sequence << :after_suite_3  }
        config.after(:suite)          { sequence << :after_suite_2  }
        config.prepend_after(:suite)  { sequence << :after_suite_1  }
        config.append_after(:suite)   { sequence << :after_suite_4  }


        example_group = class_double(ExampleGroup, :descendants => [])

        allow(example_group).to receive(:run) { sequence << :example_groups }
        allow(world).to receive_messages(:ordered_example_groups => [example_group])
        allow(config).to receive :load_spec_files

        runner = build_runner
        runner.run err, out

        expect(sequence).to eq([
          :before_suite_1,
          :before_suite_2,
          :before_suite_3,
          :before_suite_4,
          :example_groups,
          :after_suite_1,
          :after_suite_2,
          :after_suite_3,
          :after_suite_4
        ])
      end
    end
  end
end
