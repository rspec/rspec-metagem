RSpec.describe Regexp do

  it 'sets the core class as the described class' do
    expect(described_class).to eq(Regexp)
  end
end
