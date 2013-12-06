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
end

