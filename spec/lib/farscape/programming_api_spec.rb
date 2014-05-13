
describe "Farscape.get" do
  let(:url) { 'http://www.exambple.com/mumi'}
  let(:result) {'some nice result'}
  let(:options) { {option1: 'trusmis'}}

  it "calls SimpleAgent.get" do
    allow(Farscape::SimpleAgent).to receive(:get).with(url, {}).and_return(result)
    expect(Farscape.get(url)).to eq(result)
  end

  it 'pass the options to SimpleAgent' do
    allow(Farscape::SimpleAgent).to receive(:get).with(url, options).and_return(result)
    expect(Farscape.get(url, options)).to eq(result)
  end
end
