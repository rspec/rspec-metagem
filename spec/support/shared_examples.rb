shared_examples_for "an RSpec matcher" do |options|
  let(:valid_value)   { options.fetch(:valid_value) }
  let(:invalid_value) { options.fetch(:invalid_value) }

  it 'preserves the symmetric property of `==`' do
    expect(matcher).to eq(matcher)
    expect(matcher).not_to eq(valid_value)
    expect(valid_value).not_to eq(matcher)
  end

  it 'matches a valid value when using #=== so it can be composed' do
    expect(matcher).to be === valid_value
  end

  it 'does not match an invalid value when using #=== so it can be composed' do
    expect(matcher).not_to be === invalid_value
  end

  matcher :always_passes do
    match { true }
  end

  matcher :always_fails do
    match { false }
  end

  it 'supports compound expecations by chaining `and`' do
    expect(valid_value).to matcher.and always_passes
  end

  it 'supports compound expectations by chaining `or`' do
    expect(valid_value).to matcher.or always_fails
  end
end

shared_examples_for "output_to_stream" do |stream_name|
  matcher_method = :"output_to_#{stream_name}"

  define_method :matcher do |*args|
    send(matcher_method, *args)
  end

  context "expect { ... }.to #{matcher_method} (with no arg)" do
    it "passes if the block outputs to #{stream_name}" do
      expect { stream.puts 'foo' }.to matcher
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
        expect { stream.puts 'foo' }.not_to matcher
      }.to fail_with("expected block to not output to #{stream_name}, but did")
    end
  end

  context "expect { ... }.to #{matcher_method}('string')" do
    it "passes if the block outputs that string to #{stream_name}" do
      expect { stream.puts 'foo' }.to matcher("foo\n")
    end

    it "fails if the block does not outputs to #{stream_name}" do
      expect {
        expect { }.to matcher('foo')
      }.to fail_with("expected block to output \"foo\" to #{stream_name}, but output nothing")
    end

    it "fails if the block outputs a different string to #{stream_name}" do
      expect {
        expect { stream.puts 'food' }.to matcher("foo")
      }.to fail_with("expected block to output \"foo\" to #{stream_name}, but output \"food\\n\"")
    end
  end

  context "expect { ... }.to_not #{matcher_method}('string')" do
    it "passes if the block outputs a different string to #{stream_name}" do
      expect { stream.puts 'food' }.to_not matcher("foo\n")
    end

    it "passes if the block does not output to #{stream_name}" do
      expect { }.to_not matcher('foo')
    end

    it "fails if the block outputs the same string to #{stream_name}" do
      expect {
        expect { stream.puts 'foo' }.to_not matcher("foo\n")
      }.to fail_with("expected block to not output \"foo\\n\" to #{stream_name}, but did")
    end
  end
end
