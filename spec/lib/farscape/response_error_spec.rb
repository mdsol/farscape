require 'spec_helper'

describe Farscape::ResponseError do
  let(:response) { 'I am the response' }
  it 'response can be set' do
    error = Farscape::ResponseError.new(response)
    expect(error.response).to eq(response)
  end
end