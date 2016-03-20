require 'spec_helper'

describe Farscape::TransitionAgent do
  let(:client) { double }
  let(:agent) { double(media_type: :hale, client: client) }
  let(:transition) { double(uri: 'com:mdsol') }
  let(:arg) { { additional_fields: { key1: 'value1', key2: 'value2' } } }
  let(:transition_agent) { described_class.new(transition, agent) }
  let(:field_list) { double(name: 'additional_fields') }
  let(:call_options) { { url: 'com:mdsol', headers: { Accept: 'application/vnd.hale+json' } } }

  before do
    allow(agent).to receive(:get_accept_header).and_return(Accept: 'application/vnd.hale+json')
    allow(agent).to receive(:find_exception).and_return(nil)
    allow(transition).to receive(:parameters).and_return([ field_list ])
    allow(transition).to receive(:attributes).and_return([])
    allow_any_instance_of(described_class).to receive(:handle_extensions).and_return(nil)
  end

  context 'GET method' do
    before do
      allow(transition).to receive(:interface_method).and_return('get')
    end

    it 'stores parameters in params' do
      expect(client).to receive(:invoke).with(call_options.merge(method: 'get', params: arg))
      transition_agent.invoke(arg)
    end
  end

  context 'POST method' do
    before do
      allow(transition).to receive(:interface_method).and_return('post')
    end

    it 'stores parameters in body' do
      expect(client).to receive(:invoke).with(call_options.merge(method: 'post', body: arg))
      transition_agent.invoke(arg)
    end
  end
end
