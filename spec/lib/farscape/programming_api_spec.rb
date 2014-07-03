
describe Farscape do
  describe  "basic invoke" do
    let(:url) { 'http://www.exambple.com/mumi'}
    let(:result) {'some nice result'}
    let(:options) { {option1: 'trusmis'}}

    it "calls SimpleAgent.invoke" do
      allow(Farscape::SimpleAgent).to receive(:invoke).with(url, {}).and_return(result)
      expect(Farscape.invoke(url)).to eq(result)
    end

    it 'pass the options to SimpleAgent' do
      allow(Farscape::SimpleAgent).to receive(:invoke).with(url, options).and_return(result)
      expect(Farscape.invoke(url, options)).to eq(result)
    end
  end

  describe '.invoke' do
    let(:url) { 'http://www.example.com/mumi'}
    let(:body) {
        {
          attributes:{
            'title' => {value: 'The Neverending Story'},
          },
          transitions: [
            {
            href: '/mike',
            rel: 'self',
            }
          ]
        }.to_json
    }

    before(:each) do
      stub_request(:get, "http://www.example.com/mumi").
             with(:headers => {'Accept'=>'application/vnd.hale+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
             to_return(:status => 200, :body => body, :headers => {})
    end
    it "calls SimpleAgent.invoke" do
      expect(Farscape.invoke(url).properties).to eq({'title' => {value: 'The Neverending Story'}})
    end

  end
end

