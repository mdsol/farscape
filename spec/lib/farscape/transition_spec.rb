require 'spec_helper'

describe Farscape::TransitionAgent do
  let(:client) { double }
  let(:agent) { double(media_type: :hale, client: client) }
  let(:transition) { double(uri: 'com:mdsol', templated?: false) }
  let(:arg) { { additional_fields: { key1: 'value1', key2: 'value2' } } }
  let(:transition_agent) { described_class.new(transition, agent) }
  let(:field_list) { double(name: 'additional_fields') }
  let(:call_options) { { url: 'com:mdsol', headers: { 'Accept' => 'application/vnd.hale+json' } } }

  before do
    allow(agent).to receive(:get_accept_header).and_return('Accept' => 'application/vnd.hale+json')
    allow(agent).to receive(:find_exception).and_return(nil)
    allow(transition).to receive(:interface_method).and_return(http_method)
    allow(transition).to receive(:parameters).and_return([ field_list ])
    allow(transition).to receive(:attributes).and_return([])
    allow_any_instance_of(described_class).to receive(:handle_extensions).and_return(nil)
  end

  context 'GET method' do
    let(:http_method) { "get" }

    it 'stores parameters in params' do
      expect(client).to receive(:invoke).with(call_options.merge(method: http_method, params: arg))
      transition_agent.invoke(arg)
    end
  end

  context 'POST method' do
    let(:http_method) { "post" }

    it 'stores parameters in body' do
      expect(client).to receive(:invoke).with(call_options.merge(method: http_method, body: arg))
      transition_agent.invoke(arg)
    end
  end

  # see https://tools.ietf.org/html/rfc6570#section-3.2.6
  context "URL with a path segment" do
    let(:transition) do
      Representors::Transition.new(
        templated: true,
        rel: "find",
        href: "https://example.com/api/v1/issues{/issue_uuid}"
      )
    end
    let(:issue_uuid) { SecureRandom.uuid }

    context "GET" do
      let(:http_method) { "get" }

      it "interpolates a templated URI in lowercase" do
        options = call_options.merge(
          method: http_method,
          url: "https://example.com/api/v1/issues/#{issue_uuid}",
          params: arg
        )
        expect(client).to receive(:invoke).with(options)
        transition_agent.invoke(arg.merge(issue_uuid: issue_uuid.upcase))
      end
    end

    context "POST" do
      let(:http_method) { "post" }

      it "does not interpolate a templated URI" do
        params = arg.merge(issue_uuid: issue_uuid)
        options = call_options.merge(
          method: http_method,
          url: "https://example.com/api/v1/issues",
          body: params
        )
        expect(client).to receive(:invoke).with(options)
        transition_agent.invoke(params)
      end
    end
  end
end
