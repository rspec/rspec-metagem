require 'rspec/core/formatters/snippet_extractor'

module RSpec::Core::Formatters
  RSpec.describe SnippetExtractor do
    subject(:expression_lines) do
      SnippetExtractor.extract_expression_lines_at(file_path, line_number, max_line_count)
    end

    let(:file_path) do
      location[0]
    end

    let(:line_number) do
      location[1]
    end

    let(:location) do
      error.backtrace.find do |line|
        !line.include?('do_something_fail') && line.match(%r{\A(.+?):(\d+)})
      end

      location = Regexp.last_match.captures
      location[1] = location[1].to_i
      location
    end

    let(:max_line_count) do
      nil
    end

    let(:error) do
      begin
        source
      rescue ExpectedError => error
        error
      ensure
        raise 'No ExpectedError has been raised' unless error
      end
    end

    ExpectedError = Class.new(StandardError)

    # We use this helper method to raise an error while allowing any arguments,
    #
    # Note that MRI 1.9 strangely reports backtrace line as the first argument line instead of the
    # beginning of the method invocation. It's not SnippetExtractor's fault and even affects to the
    # simple single line extraction.
    def do_something_fail(*)
      raise ExpectedError
    end

    def another_expression(*)
    end

    context 'when the given file does not exist' do
      let(:file_path) do
        '/non-existent.rb'
      end

      let(:line_number) do
        1
      end

      it 'raises NoSuchFileError' do
        expect { expression_lines }.to raise_error(SnippetExtractor::NoSuchFileError)
      end
    end

    context 'when the given line does not exist in the file' do
      let(:file_path) do
        __FILE__
      end

      let(:line_number) do
        99999
      end

      it 'raises NoSuchLineError' do
        expect { expression_lines }.to raise_error(SnippetExtractor::NoSuchLineError)
      end
    end

    context 'when the expression fits into a single line' do
      let(:source) do
        do_something_fail :foo
      end

      it 'returns the line' do
        expect(expression_lines).to eq([
          '        do_something_fail :foo'
        ])
      end
    end

    context 'in Ripper supported environment', :if => RSpec::Support::RubyFeatures.ripper_supported? do
      context 'when the expression spans multiple lines' do
        let(:source) do
          do_something_fail :foo,
                            :bar
        end

        it 'returns the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail :foo,',
            '                            :bar'
          ])
        end
      end

      context 'when the expression ends with ")"-only line' do
        let(:source) do
          do_something_fail(:foo
          )
        end

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail(:foo',
            '          )'
          ])
        end
      end

      context 'when the expression ends with "}"-only line' do
        let(:source) do
          do_something_fail {
          }
        end

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail {',
            '          }'
          ])
        end
      end

      context 'when the expression ends with "]"-only line' do
        let(:source) do
          do_something_fail :foo, [
          ]
        end

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail :foo, [',
            '          ]'
          ])
        end
      end

      context "when the expression ends with multiple paren-only lines of same type" do
        let(:source) do
          do_something_fail(:foo, (:bar
            )
          )
        end

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail(:foo, (:bar',
            '            )',
            '          )'
          ])
        end
      end

      context "when the expression includes paren and heredoc pairs as non-nested structure" do
        let(:source) do
          do_something_fail(<<-END)
            foo
          END
        end

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail(<<-END)',
            '            foo',
            '          END'
          ])
        end
      end

      context 'when the expression spans lines after the closing paren line' do
        let(:source) do
          do_something_fail(:foo
          ).
          do_something_chain
        end

        # [:program,
        #  [[:call,
        #    [:method_add_arg, [:fcall, [:@ident, "do_something_fail", [1, 10]]], [:arg_paren, nil]],
        #    :".",
        #    [:@ident, "do_something_chain", [3, 10]]]]]

        it 'returns all the lines' do
          expect(expression_lines).to eq([
            '          do_something_fail(:foo',
            '          ).',
            '          do_something_chain'
          ])
        end
      end

      context "when the expression's final line includes the same type of opening paren of another multiline expression" do
        let(:source) do
          do_something_fail(:foo
          ); another_expression(:bar
          )
        end

        it 'ignores another expression' do
          expect(expression_lines).to eq([
            '          do_something_fail(:foo',
            '          ); another_expression(:bar'
          ])
        end
      end

      context "when the expression's first line includes a closing paren of another multiline expression" do
        let(:source) do
          another_expression(:bar
          ); do_something_fail(:foo
          )
        end

        it 'ignores another expression' do
          expect(expression_lines).to eq([
            '          ); do_something_fail(:foo',
            '          )'
          ])
        end
      end

      context 'when no expression exists at the line' do
        let(:file_path) do
          __FILE__
        end

        let(:line_number) do
          __LINE__ + 1
          # The failure happened here without expression
        end

        it 'returns the line by falling back to the simple single line extraction' do
          expect(expression_lines).to eq([
            '          # The failure happened here without expression'
          ])
        end
      end

      context 'when max line count is given' do
        let(:max_line_count) do
          2
        end

        let(:source) do
          do_something_fail "line1", [
            "line2",
            "line3"
          ]
        end

        it 'returns the lines without exceeding the given count' do
          expect(expression_lines).to eq([
            '          do_something_fail "line1", [',
            '            "line2",'
          ])
        end
      end

      context 'when max line count is 1' do
        let(:max_line_count) do
          1
        end

        let(:source) do
          do_something_fail "line1", [
            "line2",
            "line3"
          ]
        end

        before do
          RSpec.reset # Clear source cache
        end

        it 'returns the line without parsing the source for efficiency' do
          require 'ripper'
          expect(Ripper).not_to receive(:sexp)
          expect(expression_lines).to eq([
            '          do_something_fail "line1", ['
          ])
        end
      end
    end

    context 'in Ripper unsupported environment', :unless => RSpec::Support::RubyFeatures.ripper_supported? do
      context 'when the expression spans multiple lines' do
        let(:source) do
          do_something_fail :foo,
                            :bar
        end

        it 'returns only the first line' do
          expect(expression_lines).to eq([
            '          do_something_fail :foo,'
          ])
        end
      end
    end
  end
end
