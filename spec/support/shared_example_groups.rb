RSpec.shared_examples_for "metadata hash builder" do
  let(:hash) { metadata_hash(:foo, :bar, :bazz => 23) }

  it 'treats symbols as metadata keys with a true value' do
    expect(hash[:foo]).to be(true)
    expect(hash[:bar]).to be(true)
  end

  it 'still processes hash values normally' do
    expect(hash[:bazz]).to be(23)
  end
end

