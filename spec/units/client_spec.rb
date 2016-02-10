require 'spec_helper'

describe ApiDotAi::Client do
  let(:token) { credentials['client_access_token'] }
  let(:key)   { credentials['subscription_key'] }
  subject     { described_class.new client_access_token: token, subscription_key: key }

  it 'has credentials' do
    expect(subject.client_access_token).to eq token
    expect(subject.subscription_key).to eq key
  end

  it 'creates a QueryRequest' do
    expect(subject.query).to be_a ApiDotAi::QueryRequest
  end

end

describe ApiDotAi::Client, "#make" do
  let(:token)   { 'bar' }
  let(:key)     { 'foo' }
  subject       { described_class.new client_access_token: token, subscription_key: key }

  it 'returns HTTPResponse after making HTTPS request' do
    request = double(path: 'query', verb: 'POST')
    headers = {
      'Authorization'             => 'Bearer #{token}',
      'Ocp-Apim-Subscription-Key' => key
    }

    stub_request(:post, ApiDotAi::Client::BASE_URL + 'query')
      .to_return(body: "{'a':'b'}", status: 200)

    response = subject.make(request)
    expect(response).to be_a Net::HTTPSuccess
    expect(response.body).to eq "{'a':'b'}"
  end
end

describe ApiDotAi::Client, "#make!" do
  let(:token)   { 'bar' }
  let(:key)     { 'foo' }
  let(:request) { double(path: 'query', verb: 'POST') }
  subject       { described_class.new client_access_token: token, subscription_key: key }

  it 'returns HTTPResponse after making successful HTTPS request' do
    stub_request(:post, ApiDotAi::Client::BASE_URL + 'query')
      .to_return(body: "{'a':'b'}", status: 200)

    response = subject.make!(request)
    expect(response).to be_a Net::HTTPSuccess
    expect(response.body).to eq "{'a':'b'}"
  end

  it 'raises exception after making unsuccessful HTTPS request' do
    stub_request(:post, ApiDotAi::Client::BASE_URL + 'query')
      .to_return(body: "{'a':'b'}", status: 400)

    expect{subject.make!(request)}.to raise_error(ApiDotAi::FailedRequest)
  end
end
