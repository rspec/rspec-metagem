require 'spec_helper'

shared_examples_for "output_to_stream" do |stream_name|
  matcher_method = :"output_to_#{stream_name}"

  define_method :matcher do |*args|
    send(matcher_method, *args)
  end

  context "expect { ... }.to #{matcher_method} (with no arg)" do
    it "passes if the block outputs to #{stream_name}" do
      expect { stream.print 'foo' }.to matcher
    end

    it "fails if the block does not output to #{stream_name}" do
      expect {
        expect { }.to matcher
      }.to fail_with("expected block to output to #{stream_name}, but did not")
    end
  end

  context "expect { ... }.not_to #{matcher_method} (with no arg)" do
    it "passes if the block does not output to #{stream_name}" do
      expect { }.not_to matcher
    end

    it "fails if the block outputs to #{stream_name}" do
      expect {
        expect { stream.print 'foo' }.not_to matcher
      }.to fail_with("expected block to not output to #{stream_name}, but did")
    end
  end

  context "expect { ... }.to #{matcher_method}('string')" do
    it "passes if the block outputs that string to #{stream_name}" do
      expect { stream.print 'foo' }.to matcher("foo")
    end

    it "fails if the block does not output to #{stream_name}" do
      expect {
        expect { }.to matcher('foo')
      }.to fail_with("expected block to output \"foo\" to #{stream_name}, but output nothing")
    end

    it "fails if the block outputs a different string to #{stream_name}" do
      expect {
        expect { stream.print 'food' }.to matcher('foo')
      }.to fail_with("expected block to output \"foo\" to #{stream_name}, but output \"food\"")
    end
  end

  context "expect { ... }.to_not #{matcher_method}('string')" do
    it "passes if the block outputs a different string to #{stream_name}" do
      expect { stream.print 'food' }.to_not matcher('foo')
    end

    it "passes if the block does not output to #{stream_name}" do
      expect { }.to_not matcher('foo')
    end

    it "fails if the block outputs the same string to #{stream_name}" do
      expect {
        expect { stream.print 'foo' }.to_not matcher('foo')
      }.to fail_with("expected block to not output \"foo\" to #{stream_name}, but did")
    end
  end

  context "expect { ... }.to #{matcher_method}(/regex/)" do
    it "passes if the block outputs a string to #{stream_name} that matches the regex" do
      expect { stream.print 'foo' }.to matcher(/foo/)
    end

    it "fails if the block does not output to #{stream_name}" do
      expect {
        expect { }.to matcher(/foo/)
      }.to fail_with("expected block to output /foo/ to #{stream_name}, but output nothing")
    end

    it "fails if the block outputs a string to #{stream_name} that does not match" do
      expect {
        expect { stream.print 'foo' }.to matcher(/food/)
      }.to fail_with("expected block to output /food/ to #{stream_name}, but output \"foo\"")
    end
  end

  context "expect { ... }.to_not #{matcher_method}(/regex/)" do
    it "passes if the block outputs a string to #{stream_name} that does not match the regex" do
      expect { stream.print 'food' }.to_not matcher(/bar/)
    end

    it "passes if the block does not output to #{stream_name}" do
      expect { }.to_not matcher(/foo/)
    end

    it "fails if the block outputs a string to #{stream_name} that matches the regex" do
      expect {
        expect { stream.print 'foo' }.to_not matcher(/foo/)
      }.to fail_with("expected block to not output /foo/ to #{stream_name}, but did")
    end
  end

  context "expect { ... }.to #{matcher_method}(matcher)" do
    it "passes if the block outputs a string to #{stream_name} that passes the given matcher" do
      expect { stream.print 'foo' }.to matcher(a_string_starting_with("f"))
    end

    it "fails if the block outputs a string to #{stream_name} that does not pass the given matcher" do
      expect {
        expect { stream.print 'foo' }.to matcher(a_string_starting_with("b"))
      }.to fail_with("expected block to output a string starting with \"b\" to #{stream_name}, but output \"foo\"")
    end
  end

  context "expect { ... }.to_not #{matcher_method}(matcher)" do
    it "passes if the block does not output a string to #{stream_name} that passes the given matcher" do
      expect { stream.print 'foo' }.to_not matcher(a_string_starting_with("b"))
    end

    it "fails if the block outputs a string to #{stream_name} that passes the given matcher" do
      expect {
        expect { stream.print 'foo' }.to_not matcher(a_string_starting_with("f"))
      }.to fail_with("expected block to not output a string starting with \"f\" to #{stream_name}, but did")
    end
  end
end

module RSpec
  module Matchers
    describe "output_to_stderr matcher" do
      it_behaves_like("an RSpec matcher", :valid_value => lambda { warn('foo') }, :invalid_value => lambda {}) do
        let(:matcher) { output_to_stderr }
      end

      include_examples "output_to_stream", :stderr do
        let(:stream) { $stderr }
      end
    end

    describe "output_to_stdout matcher" do
      it_behaves_like("an RSpec matcher", :valid_value => lambda { print 'foo' }, :invalid_value => lambda {}) do
        let(:matcher) { output_to_stdout }
      end

      include_examples "output_to_stream", :stdout do
        let(:stream) { $stdout }
      end
    end
  end
end
