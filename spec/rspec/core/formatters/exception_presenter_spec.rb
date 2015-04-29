require 'pathname'

module RSpec::Core
  RSpec.describe Formatters::ExceptionPresenter do
    include FormatterSupport

    let(:example) { new_example }
    let(:presenter) { Formatters::ExceptionPresenter.new(exception, example) }

    before do
      allow(example.execution_result).to receive(:exception) { exception }
      example.metadata[:absolute_file_path] = __FILE__
    end

    describe "#fully_formatted" do
      line_num = __LINE__ + 2
      let(:exception) { instance_double(Exception, :message => "Boom\nBam", :backtrace => [ "#{__FILE__}:#{line_num}"]) }
      # The failure happened here!

      it "formats the exception with all the normal details" do
        expect(presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  1) Example
          |     Failure/Error: # The failure happened here!
          |       Boom
          |       Bam
          |     # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it "indents properly when given a multiple-digit failure index" do
        expect(presenter.fully_formatted(100)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |  100) Example
          |       Failure/Error: # The failure happened here!
          |         Boom
          |         Bam
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

      it "allows the caller to specify additional indentation" do
        presenter = Formatters::ExceptionPresenter.new(exception, example, :indentation => 4)

        expect(presenter.fully_formatted(1)).to eq(<<-EOS.gsub(/^ +\|/, ''))
          |
          |    1) Example
          |       Failure/Error: # The failure happened here!
          |         Boom
          |         Bam
          |       # ./spec/rspec/core/formatters/exception_presenter_spec.rb:#{line_num}
        EOS
      end

    end

    describe "#read_failed_line" do
      def read_failed_line
        presenter.send(:read_failed_line)
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
          expect { read_failed_line }.not_to raise_error
        end
      end

      context "when backtrace will generate a security error" do
        let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:#{__LINE__}"]) }

        it "is handled gracefully" do
          with_safe_set_to_level_that_triggers_security_errors do
            expect { read_failed_line }.not_to raise_error
          end
        end
      end

      context "when ruby reports a bogus line number in the stack trace" do
        let(:exception) { instance_double(Exception, :backtrace => [ "#{__FILE__}:10000000"]) }

        it "reports the filename and that it was unable to find the matching line" do
          expect(read_failed_line).to include("Unable to find matching line")
        end
      end

      context "when ruby reports a file that does not exist" do
        let(:file) { "#{__FILE__}/blah.rb" }
        let(:exception) { instance_double(Exception, :backtrace => [ "#{file}:1"]) }

        it "reports the filename and that it was unable to find the matching line" do
          example.metadata[:absolute_file_path] = file
          expect(read_failed_line).to include("Unable to find #{file} to read failed line")
        end
      end

      context "when the stacktrace includes relative paths (which can happen when using `rspec/autorun` and running files through `ruby`)" do
        let(:relative_file) { Pathname(__FILE__).relative_path_from(Pathname(Dir.pwd)) }
        line = __LINE__
        let(:exception) { instance_double(Exception, :backtrace => ["#{relative_file}:#{line}"]) }

        it 'still finds the backtrace line' do
          expect(read_failed_line).to include("line = __LINE__")
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
          expect(read_failed_line.strip).to eql(
            %Q[let(:exception) { instance_double(Exception, :backtrace => [ "\#{__FILE__}:\#{__LINE__}"]) }])
        end
      end
    end
  end
end
