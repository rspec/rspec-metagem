# encoding: utf-8
require 'pathname'

module RSpec::Core
  RSpec.describe Formatters::ExceptionPresenter do
    include FormatterSupport

    let(:example) { new_example }
    let(:presenter) { Formatters::ExceptionPresenter.new(exception, example) }

    before do
      allow(example.execution_result).to receive(:exception) { exception }
      example.metadata[:absolute_file_path] = __FILE__
      allow(exception).to receive(:cause) if RSpec::Support::RubyFeatures.supports_exception_cause?
    end

    describe "#fully_formatted" do
      if RSpec::Support::OS.windows?
        let(:encoding_check) { '' }
        line_num = __LINE__ + 1
        # The failure happened here!
        it 'should check that output is not mangled'
      else
        let(:encoding_check) { ' Handles encoding too! ЙЦ' }
        line_num = __LINE__ + 1
        # The failure happened here! Handles encoding too! ЙЦ
      end
      let(:exception) { instance_double(Exception, :message => "Boom\nBam", :backtrace => [ "#{__FILE__}:#{line_num}"]) }

      it "formats the exception with all the normal details" do
        expect(presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  1) Example
          |     Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it "indents properly when given a multiple-digit failure index" do
        expect(presenter.fully_formatted(100)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  100) Example
          |       Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |         Boom
          |         Bam
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it "allows the caller to specify additional indentation" do
        the_presenter = Formatters::ExceptionPresenter.new(exception, example, :indentation => 4)

        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |    1) Example
          |       Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |         Boom
          |         Bam
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it 'aligns lines' do
        detail_formatter = Proc.new { "Some Detail" }

        the_presenter = Formatters::ExceptionPresenter.new(exception, example, :indentation => 4,
                                                       :detail_formatter => detail_formatter)
        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |    1) Example
          |       Some Detail
          |       Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |         Boom
          |         Bam
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it 'allows the caller to omit the description' do
        the_presenter = Formatters::ExceptionPresenter.new(exception, example,
                                                       :detail_formatter => Proc.new { "Detail!" },
                                                       :description => nil)

        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  1) Detail!
          |     Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it 'allows the failure/error line to be used as the description' do
        the_presenter = Formatters::ExceptionPresenter.new(exception, example, :description => nil)

        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  1) Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it 'allows a caller to specify extra details that are added to the bottom' do
        the_presenter = Formatters::ExceptionPresenter.new(
          exception, example, :extra_detail_formatter => lambda do |failure_number, colorizer|
            "extra detail for failure: #{failure_number}"
          end
        )

        expect(the_presenter.fully_formatted(2)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  2) Example
          |     Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
          |     extra detail for failure: 2
        EOS
      end

      let(:the_exception) { instance_double(Exception, :cause => second_exception, :message => "Boom\nBam", :backtrace => [ "#{__FILE__}:#{line_num}"]) }

      let(:second_exception) do
        instance_double(Exception, :cause => first_exception, :message => "Second\nexception", :backtrace => ["#{__FILE__}:#{__LINE__}"])
      end

      let(:first_exception) do
        instance_double(Exception, :cause => nil, :message => "Real\nculprit", :backtrace => ["#{__FILE__}:#{__LINE__}"])
      end

      it 'includes the first exception that caused the failure', :if => RSpec::Support::RubyFeatures.supports_exception_cause? do
        the_presenter = Formatters::ExceptionPresenter.new(the_exception, example)

        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  1) Example
          |     Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
          |     # ------------------
          |     # --- Caused by: ---
          |     #   Real
          |     #   culprit
          |     #   ./spec/rspec/core/formatters/exception_presenter_spec.rb:140
        EOS
      end

      it "adds extra failure lines from the example metadata" do
        extra_example = example.clone
        failure_line = 'http://www.example.com/job_details/123'
        extra_example.metadata[:extra_failure_lines] = [failure_line]
        the_presenter = Formatters::ExceptionPresenter.new(exception, extra_example, :indentation => 4)
        expect(the_presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |    1) Example
          |       Failure/Error: # The failure happened here!#{ encoding_check }
          |
          |         Boom
          |         Bam
          |
          |       #{failure_line}
          |
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      describe 'line format' do
        let(:exception) do
          begin
            expression
          rescue RSpec::Support::AllExceptionsExceptOnesWeMustNotRescue => exception
            exception
          end
        end

        context 'with single line expression and single line RSpec exception message' do
          let(:expression) do
            expect('RSpec').to be_a(Integer)
          end

          it 'crams them without blank line' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error: expect('RSpec').to be_a(Integer)
              |       expected "RSpec" to be a kind of Integer
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with multiline expression and single line RSpec exception message', :if => RSpec::Support::RubyFeatures.ripper_supported? do
          let(:expression) do
            expect('RSpec').
              to be_a(Integer)
          end

          it 'inserts a blank line between the expression and the message' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error:
              |       expect('RSpec').
              |         to be_a(Integer)
              |
              |       expected "RSpec" to be a kind of Integer
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with single line expression and multiline RSpec exception message' do
          let(:expression) do
            expect('RSpec').to be_falsey
          end

          it 'inserts a blank line between the expression and the message' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error: expect('RSpec').to be_falsey
              |
              |       expected: falsey value
              |            got: "RSpec"
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with multiline expression and multiline RSpec exception message', :if => RSpec::Support::RubyFeatures.ripper_supported? do
          let(:expression) do
            expect('RSpec').
              to be_falsey
          end

          it 'inserts a blank line between the expression and the message' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error:
              |       expect('RSpec').
              |         to be_falsey
              |
              |       expected: falsey value
              |            got: "RSpec"
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with single line expression and RSpec exception message starting with linefeed (like `eq` matcher)' do
          let(:expression) do
            expect('Rspec').to eq('RSpec')
          end

          it 'does not insert a superfluous blank line' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error: expect('Rspec').to eq('RSpec')
              |
              |       expected: "RSpec"
              |            got: "Rspec"
              |
              |       (compared using ==)
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with multiline expression and RSpec exception message starting with linefeed (like `eq` matcher)', :if => RSpec::Support::RubyFeatures.ripper_supported? do
          let(:expression) do
            expect('Rspec').
              to eq('RSpec')
          end

          it 'does not insert a superfluous blank line' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error:
              |       expect('Rspec').
              |         to eq('RSpec')
              |
              |       expected: "RSpec"
              |            got: "Rspec"
              |
              |       (compared using ==)
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with single line expression and single line non-RSpec exception message' do
          let(:expression) do
            expect { fail 'Something is wrong!' }.to change { RSpec }
          end

          it 'inserts a blank line between the expression and the message' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error: expect { fail 'Something is wrong!' }.to change { RSpec }
              |
              |     RuntimeError:
              |       Something is wrong!
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end

        context 'with multiline expression and single line non-RSpec exception message', :if => RSpec::Support::RubyFeatures.ripper_supported? do
          let(:expression) do
            expect { fail 'Something is wrong!' }.
              to change { RSpec }
          end

          it 'inserts a blank line between the expression and the message' do
            expect(presenter.fully_formatted(1)).to start_with(<<-EOS.gsub(/^ +\|/, '').chomp)
              |
              |  1) Example
              |     Failure/Error:
              |       expect { fail 'Something is wrong!' }.
              |         to change { RSpec }
              |
              |     RuntimeError:
              |       Something is wrong!
              |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:
            EOS
          end
        end
      end
    end

    describe "#read_failed_lines" do
      def read_failed_lines
        presenter.send(:read_failed_lines)
      end

      context 'when the failed expression spans multiple lines', :if => RSpec::Support::RubyFeatures.ripper_supported? do
        let(:exception) do
          begin
            expect('RSpec').to be_a(String).
                           and start_with('R').
                           and end_with('z')
          rescue RSpec::Expectations::ExpectationNotMetError => exception
            exception
          end
        end

        context 'and the line count does not exceed RSpec.configuration.max_displayed_failure_line_count' do
          it 'returns all the lines' do
            expect(read_failed_lines).to eq([
              "            expect('RSpec').to be_a(String).",
              "                           and start_with('R').",
              "                           and end_with('z')"
            ])
          end
        end

        context 'and the line count exceeds RSpec.configuration.max_displayed_failure_line_count' do
          before do
            RSpec.configuration.max_displayed_failure_line_count = 2
          end

          it 'returns the lines without exceeding the max count' do
            expect(read_failed_lines).to eq([
              "            expect('RSpec').to be_a(String).",
              "                           and start_with('R')."
            ])
          end
        end
      end

      context "when backtrace is a heterogeneous language stack trace" do
        let(:exception) do
          instance_double(Exception, :backtrace => [
            "at Object.prototypeMethod (foo:331:18)",
            "at Array.forEach (native)",
            "at a_named_javascript_function (/some/javascript/file.js:39:5)",
            "/some/line/of/ruby.rb:14"
          ])
        end

        it "is handled gracefully" do
          expect { read_failed_lines }.not_to raise_error
        end
      end

      context "when backtrace will generate a security error" do
        let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

        before do
          # We lazily require SnippetExtractor but requiring it in $SAFE 3 environment raises error.
          RSpec::Support.require_rspec_core "formatters/snippet_extractor"
        end

        it "is handled gracefully" do
          with_safe_set_to_level_that_triggers_security_errors do
            expect { read_failed_lines }.not_to raise_error
          end
        end
      end

      context "when ruby reports a bogus line number in the stack trace" do
        let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:10000000"]) }

        it "reports the filename and that it was unable to find the matching line" do
          expect(read_failed_lines.first).to include("Unable to find matching line")
        end
      end

      context "when ruby reports a file that does not exist" do
        let(:file) { "#{__FILE__}/blah.rb" }
        let(:exception) { instance_double(Exception, :backtrace => [ "#{file}:1"]) }

        it "reports the filename and that it was unable to find the matching line" do
          example.metadata[:absolute_file_path] = file
          expect(read_failed_lines.first).to include("Unable to find #{file} to read failed line")
        end
      end

      context "when the stacktrace includes relative paths (which can happen when using `rspec/autorun` and running files through `ruby`)" do
        let(:relative_file) { Pathname(__FILE__).relative_path_from(Pathname(Dir.pwd)) }
        line = __LINE__
        let(:exception) { instance_double(Exception, :backtrace => ["#{relative_file}:#{line}"]) }

        it 'still finds the backtrace line' do
          expect(read_failed_lines.first).to include("line = __LINE__")
        end
      end

      context "when String alias to_int to_i" do
        before do
          String.class_exec do
            alias :to_int :to_i
          end
        end

        after do
          String.class_exec do
            undef to_int
          end
        end

        let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

        it "doesn't hang when file exists" do
          expect(read_failed_lines.first.strip).to eql(
            %Q[let(:exception) { instance_double(Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"]) }])
        end
      end
    end
  end

  RSpec.describe Formatters::ExceptionPresenter::Factory::CommonBacktraceTruncater do
    def truncate(parent, child)
      described_class.new(parent).with_truncated_backtrace(child)
    end

    def exception_with(backtrace)
      exception = Exception.new
      exception.set_backtrace(backtrace)
      exception
    end

    it 'returns an exception with the common part truncated' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 ]
      child  = exception_with %w[ file_1.rb:3 file_1.rb:9 foo.rb:1 bar.rb:2 car.rb:7 ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ file_1.rb:3 file_1.rb:9 ]
    end

    it 'ignores excess lines in the top of the parent trace that the child does not have' do
      parent = exception_with %w[ foo.rb:1 foo.rb:2 foo.rb:3 bar.rb:2 car.rb:7 ]
      child  = exception_with %w[ file_1.rb:3 file_1.rb:9 bar.rb:2 car.rb:7 ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ file_1.rb:3 file_1.rb:9 ]
    end

    it 'does not truncate anything if the parent has excess lines at the bottom of the trace' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 bazz.rb:9 ]
      child  = exception_with %w[ file_1.rb:3 file_1.rb:9 foo.rb:1 bar.rb:2 car.rb:7 ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ file_1.rb:3 file_1.rb:9 foo.rb:1 bar.rb:2 car.rb:7 ]
    end

    it 'does not mutate the provided exception' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 ]
      child  = exception_with %w[ file_1.rb:3 file_1.rb:9 foo.rb:1 bar.rb:2 car.rb:7 ]

      expect { truncate(parent, child) }.not_to change(child, :backtrace)
    end

    it 'returns an exception with all the same attributes (except backtrace) as the provided one' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 ]

      my_custom_exception_class = Class.new(StandardError) do
        attr_accessor :foo, :bar
      end

      child = my_custom_exception_class.new("Some Message")
      child.foo = 13
      child.bar = 20
      child.set_backtrace(%w[ foo.rb:1 ])

      truncated = truncate(parent, child)

      expect(truncated).to have_attributes(
        :message => "Some Message",
        :foo => 13,
        :bar => 20
      )
    end

    it 'handles child exceptions that have a blank array for the backtrace' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 ]
      child  = exception_with %w[ ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ ]
    end

    it 'handles child exceptions that have `nil` for the backtrace' do
      parent = exception_with %w[ foo.rb:1 bar.rb:2 car.rb:7 ]
      child  = Exception.new

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to be_nil
    end

    it 'handles parent exceptions that have a blank array for the backtrace' do
      parent = exception_with %w[ ]
      child  = exception_with %w[ foo.rb:1 ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ foo.rb:1 ]
    end

    it 'handles parent exceptions that have `nil` for the backtrace' do
      parent = Exception.new
      child  = exception_with %w[ foo.rb:1 ]

      truncated = truncate(parent, child)

      expect(truncated.backtrace).to eq %w[ foo.rb:1 ]
    end

    it 'returns the original exception object (not a dup) when there is no need to update the backtrace' do
      parent = exception_with %w[ bar.rb:1 ]
      child  = exception_with %w[ foo.rb:1 ]

      truncated = truncate(parent, child)

      expect(truncated).to be child
    end
  end

  RSpec.shared_examples_for "a class satisfying the common multiple exception error interface" do
    def new_failure(*a)
      RSpec::Expectations::ExpectationNotMetError.new(*a)
    end

    def new_error(*a)
      StandardError.new(*a)
    end

    it 'allows you to keep track of failures and other errors in order' do
      mee = new_multiple_exception_error

      f1 = new_failure
      e1 = new_error
      f2 = new_failure

      expect { mee.add(f1) }.to change(mee, :failures).to [f1]
      expect { mee.add(e1) }.to change(mee, :other_errors).to [e1]
      expect { mee.add(f2) }.to change(mee, :failures).to [f1, f2]

      expect(mee.all_exceptions).to eq([f1, e1, f2])
    end

    it 'allows you to add exceptions of an anonymous class' do
      mee = new_multiple_exception_error

      expect {
        mee.add(Class.new(StandardError).new)
      }.to change(mee.other_errors, :count).by 1
    end

    it 'ignores `Pending::PendingExampleFixedError` since it does not represent a real failure but rather the lack of one' do
      mee = new_multiple_exception_error

      expect {
        mee.add Pending::PendingExampleFixedError.new
      }.to avoid_changing(mee.other_errors, :count).
       and avoid_changing(mee.all_exceptions, :count).
       and avoid_changing(mee.failures, :count)
    end

    it 'is tagged with a common module so it is clear it has the interface for multiple exceptions' do
      expect(MultipleExceptionError::InterfaceTag).to be === new_multiple_exception_error
    end
  end

  RSpec.describe RSpec::Expectations::ExpectationNotMetError do
    include_examples "a class satisfying the common multiple exception error interface" do
      def new_multiple_exception_error
        failure_aggregator = RSpec::Expectations::FailureAggregator.new(nil, {})
        RSpec::Expectations::MultipleExpectationsNotMetError.new(failure_aggregator)
      end
    end
  end

  RSpec.describe MultipleExceptionError do
    include_examples "a class satisfying the common multiple exception error interface" do
      def new_multiple_exception_error
        MultipleExceptionError.new
      end
    end

    it 'supports the same interface as `RSpec::Expectations::MultipleExpectationsNotMetError`' do
      skip "Skipping to allow an rspec-expectations PR to add a new method and remain green" if ENV['NEW_MUTLI_EXCEPTION_METHOD']

      aggregate_failures { } # force autoload

      interface = RSpec::Expectations::MultipleExpectationsNotMetError.instance_methods - Exception.instance_methods
      expect(MultipleExceptionError.new).to respond_to(*interface)
    end

    it 'allows you to instantiate it with an initial list of exceptions' do
      mee = MultipleExceptionError.new(f1 = new_failure, e1 = new_error)

      expect(mee).to have_attributes(
        :failures       => [f1],
        :other_errors   => [e1],
        :all_exceptions => [f1, e1]
      )
    end

    specify 'the `message` implementation provides all failure messages, but is not well formatted because we do not actually use it' do
      mee = MultipleExceptionError.new(
        new_failure("failure 1"),
        new_error("error 1")
      )

      expect(mee.message).to include("failure 1", "error 1")
    end

    it 'provides a description of the exception counts, correctly categorized as failures or exceptions' do
      mee = MultipleExceptionError.new

      expect {
        mee.add new_failure
        mee.add new_error
      }.to change(mee, :exception_count_description).
        from("0 failures").
        to("1 failure and 1 other error")

      expect {
        mee.add new_failure
        mee.add new_error
      }.to change(mee, :exception_count_description).
        to("2 failures and 2 other errors")
    end

    it 'provides a summary of the exception counts' do
      mee = MultipleExceptionError.new

      expect {
        mee.add new_failure
        mee.add new_error
      }.to change(mee, :summary).
        from("Got 0 failures").
        to("Got 1 failure and 1 other error")

      expect {
        mee.add new_failure
        mee.add new_error
      }.to change(mee, :summary).
        to("Got 2 failures and 2 other errors")
    end

    it 'presents the same aggregation metadata that an `:aggregate_failures`-tagged example produces' do
      ex = nil

      RSpec.describe do
        ex = it "", :aggregate_failures do
          expect(1).to eq(2)
          expect(1).to eq(2)
        end
      end.run

      expected_metadata = ex.exception.aggregation_metadata
      expect(MultipleExceptionError.new.aggregation_metadata).to eq(expected_metadata)
    end

    describe "::InterfaceTag.for" do
      def value_for(ex)
        described_class::InterfaceTag.for(ex)
      end

      context "when given an `#{described_class.name}`" do
        it 'returns the provided error' do
          ex = MultipleExceptionError.new
          expect(value_for ex).to be ex
        end
      end

      context "when given an `RSpec::Expectations::MultipleExpectationsNotMetError`" do
        it 'returns the provided error' do
          failure_aggregator = RSpec::Expectations::FailureAggregator.new(nil, {})
          ex = RSpec::Expectations::MultipleExpectationsNotMetError.new(failure_aggregator)

          expect(value_for ex).to be ex
        end
      end

      context "when given any other exception" do
        it 'wraps it in a `RSpec::Expectations::MultipleExceptionError`' do
          ex = StandardError.new
          expect(value_for ex).to be_a(MultipleExceptionError).and have_attributes(:all_exceptions => [ex])
        end
      end
    end
  end
end
