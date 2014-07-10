require 'spec_helper'

module Farscape
  describe Representor do
    let(:empty_representor) { ::Representors::Representor.new}
    let(:result) { 'The result' }
    let(:empty_farscape_representor) { Representor.new(empty_representor, result)}

    describe '.new' do
      it 'returns the correct class' do
        expect(empty_farscape_representor.class).to eq(Farscape::Representor)
      end
      it '#instance_of? is correct' do
        expect(empty_farscape_representor).to be_instance_of(Farscape::Representor)
      end

      it '#instance_of? OtherClass is false' do
        expect(empty_farscape_representor).to_not be_instance_of(Farscape::SimpleAgent)
      end
    end

    describe '#agent' do
      it 'gives access to the result object' do
        expect(empty_farscape_representor.agent).to eq(result)
      end
    end

    describe '#transitions' do
      let(:document) {
        {
          '_links' => {
            'self' => {'href' => 'http://www.authors.com/mike'}
          }
        }.to_json
      }
      let(:representor_data) { Representors::DeserializerFactory.build(:hal, document).to_representor}
      let(:representor) {Representor.new(representor_data, 'result')}
      it 'returns an array with one Farscape transition' do
        expect(representor.transitions).to have(1).item
        expect(representor.transitions.first).to be_instance_of(Farscape::Transition)
      end
      it 'returns the proper transition' do
        expect(representor.transitions.first.rel).to eq('self')
      end
    end

    describe '#invoke' do
      before(:each) do
        stub_request(:get, "http://www.authors.com/mike").
          with(:headers => {'Accept'=>'application/vnd.hale+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => author_document, :headers => {'Content-Type' => 'application/hal+json'})
      end
      let(:author_name) {'Michael Ende'}
      let(:author_document) {
        {
          'name' => author_name,
          '_links' => {
            'self' => {'href' => 'http://www.authors.com/mike'}
          },
          '_meta' => {
            'any' => { 'json' => 'thing'}
          }
        }.to_json
      }
      let(:hal_document) {
        {
          'title' => 'The Neverending Story',
          '_links' => {
            'author' => {'href' => 'http://www.authors.com/mike'}
          },
          '_meta' => {
            'any' => { 'json' => 'thing'}
          }
        }.to_json
      }
      let(:representor_data) { Representors::DeserializerFactory.build(:hal, hal_document).to_representor}
      let(:representor) {Representor.new(representor_data, result)}

      it 'returns an object when following a link that exists' do
        expect(representor.invoke('author')).to be_instance_of(Farscape::Representor)
      end

      it 'can access properties of objects obtained by following links' do
        expect(representor.invoke('author').properties['name']).to eq(author_name)
      end

      it 'als' do
         expect{representor.invoke('non_existing_link')}.to raise_error(Farscape::UnknownTransition)
       end
    end

  end
end