RSpec.describe 'RSpec::Core::LookupSet' do

  let(:set) { RSpec::Core::LookupSet.new([1, 2, 3]) }

  it 'takes an array of values' do
    expect(set).to include(1, 2, 3)
  end

  it 'can be appended to' do
    set << 4
    expect(set).to include 4
  end

  it 'can have more values merged in' do
    set.merge([4, 5]).merge([6])
    expect(set).to include(4, 5, 6)
  end

  it 'is enumerable' do
    expect(set).to be_an Enumerable
    expect { |p| set.each(&p) }.to yield_successive_args(1, 2, 3)
  end
end
