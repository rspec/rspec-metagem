shared_examples "an RSpec matcher" do |options|
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

  it 'supports compound expectations by chaining `and`' do
    expect(valid_value).to matcher.and always_passes
  end

  it 'supports compound expectations by chaining `or`' do
    expect(valid_value).to matcher.or always_fails
  end

  it 'implements the full matcher protocol' do
    expect(matcher).to respond_to(
      :matches?,
      :failure_message,
      :description,
      :supports_block_expectations?
    )

    # We do not require failure_message_when_negated and does_not_match?
    # Because some matchers purposefully do not support negation.
  end
end

