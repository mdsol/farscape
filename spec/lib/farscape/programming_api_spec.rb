require 'spec_helper'

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

  describe '.invoke get' do
    let(:url) { 'http://www.example.com/mumi'}
    let(:self_url) { 'http://www.example.com/mike'}
    let(:publisher_url) { 'http://www.example.com/acme_books'}
    let(:publisher_body) {
      {
        address: {street: 'roadrunner 1'},
        _links: {
          self: {
            href: publisher_url,
          }
        }
      }.to_json
    }

    let(:body) {
      {
        title: {value: 'The Neverending Story'},
        _links: {
          self: {
            href: self_url,
          },
          publisher: {
            href: publisher_url,
          }
        }
      }.to_json
    }

    before(:each) do
      stub_request(:get, "http://www.example.com/mumi").
        with(:headers => {'Accept'=>'application/vnd.hale+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => body, :headers => {'Content-Type'=>'application/vnd.hale+json'})

     stub_request(:get, "http://www.example.com/mike").
       with(:headers => {'Accept'=>'application/vnd.hale+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => body, :headers => {'Content-Type'=>'application/vnd.hale+json'})

     stub_request(:get, "http://www.example.com/acme_books").
       with(:headers => {'Accept'=>'application/vnd.hale+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => publisher_body, :headers => {'Content-Type'=>'application/vnd.hale+json'})
    end

    it "calls SimpleAgent.invoke" do
      expect(Farscape.invoke(url).properties).to eq({'title' => {'value' => 'The Neverending Story'}})
    end

    it 'follows self links' do
      expect(Farscape.invoke(url).invoke('self').properties).to eq({'title' => {'value' => 'The Neverending Story'}})
    end

    it 'follows self links' do
      expect(Farscape.invoke(url).invoke('publisher').properties).to eq({'address' => {'street' => 'roadrunner 1'}})
    end

  end


  describe '.invoke post' do
    let(:url) { 'http://www.example.com/mumi'}
    let(:self_url) { 'http://www.example.com/mike'}
    let(:publisher_url) { 'http://www.example.com/acme_books'}

    let(:body) {
      {
        title: {value: 'The Neverending Story'},
        _links: {
          self: {
            href: self_url,
          },
          create: {
            href: create_url,
            method: 'POST',
            data: {
              title: {
                minlength: 4,
                maxlength: 30,
                required: true,
                profile: "http://alps.io/schema.org/Person#givenName"
              }
            }
          }
        }
      }.to_json
    }

    it 'follows self links' do
      expect(Farscape.invoke(url).invoke('create', {title: 'Slaughter house 5'}).properties).to eq(1)
    end


end

