require 'spec_helper'


describe Farscape::SimpleAgent do

  describe '.get' do
    let(:get_url) {'http://www.my-site.org/test_site'}
    let(:get_url_for_hale) {'http://www.my-site.org/test_site_hale'}
    let(:get_url_for_xhtml) {'http://www.my-site.org/test_site_xhtml'}
    let(:get_url_for_unknown) {'http://www.my-site.org/test_site_trusmis'}

    before do
      stub_request(:get, get_url).
        to_return(status: 200, body: {my_key: 'my_value'}.to_json,
          headers: {'Content-Type' => 'application/json'})

      stub_request(:get, get_url_for_hale).
        with( headers: {'Accept' => 'application/vnd.hale+json'}).
        to_return(status: 200, body: {my_key: 'my_value'}.to_json,
          headers: {'Content-Type' => 'application/json'})

      stub_request(:get, get_url_for_xhtml).
        with( headers: {'Accept' => 'application/xhtml'}).
        to_return(status: 200, body: {key_in_xhtml: 'my_value'}.to_json,
          headers: {'Content-Type' => 'application/json'})

    end

    it 'returns an object to access the data of the document' do
      expect(Farscape::SimpleAgent.invoke(get_url)).to be_instance_of Farscape::Representor
    end

    it 'returns an object with the correct data' do
      expect(Farscape::SimpleAgent.invoke(get_url_for_hale).properties['my_key']).to eq('my_value')
    end

    it 'accepts an options hash that overwrites defaults' do
      result = Farscape::SimpleAgent.invoke(get_url_for_xhtml, headers: {'Accept' => 'application/xhtml'})
      expect(result.properties['key_in_xhtml']).to eq('my_value')
    end

    context 'unknown format' do
      before do
        stub_request(:get, get_url_for_unknown).
          to_return(status: 200, body: {my_key: 'my_value'}.to_json,
            headers: {'Content-Type' => 'application/unknown_format'})
      end
      it 'returns an empty Golem for an unknown media-type' do
        expect{Farscape::SimpleAgent.invoke(get_url_for_unknown)}.to raise_error(Farscape::ResponseError)
      end
    end
  end


end
