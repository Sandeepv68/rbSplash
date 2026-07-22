# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RbSplash::HttpClient do
  let(:headers) { { 'Content-type' => 'application/json' } }

  describe '#make_request' do
    it 'raises ArgumentError when URL is nil' do
      client = described_class.new(headers: headers)
      expect { client.make_request(nil, 'GET') }.to raise_error(ArgumentError, 'URL required')
    end

    it 'raises ArgumentError when URL is empty' do
      client = described_class.new(headers: headers)
      expect { client.make_request('', 'GET') }.to raise_error(ArgumentError, 'URL required')
    end

    it 'makes a GET request and returns a Response' do
      stub_request(:get, 'https://api.unsplash.com/photos')
        .to_return(status: 200, body: '{"id":"123","urls":{"raw":"http://example.com"}}')

      client = described_class.new(headers: headers)
      result = client.make_request('https://api.unsplash.com/photos', 'GET')

      expect(result).to be_a(RbSplash::Response)
      expect(result.status).to eq(200)
      expect(result.data['id']).to eq('123')
    end

    it 'makes a POST request with body' do
      stub_request(:post, 'https://unsplash.com/oauth/token')
        .with(body: hash_including('client_id' => 'test'))
        .to_return(status: 200, body: '{"access_token":"token123"}')

      client = described_class.new(headers: headers)
      result = client.make_request('https://unsplash.com/oauth/token', 'POST', body: { client_id: 'test' })

      expect(result.status).to eq(200)
      expect(result.data['access_token']).to eq('token123')
    end

    it 'makes a PUT request' do
      stub_request(:put, 'https://api.unsplash.com/me')
        .to_return(status: 200, body: '{"username":"updated"}')

      client = described_class.new(headers: headers)
      result = client.make_request('https://api.unsplash.com/me', 'PUT')

      expect(result.status).to eq(200)
    end

    it 'makes a DELETE request' do
      stub_request(:delete, 'https://api.unsplash.com/photos/123/like')
        .to_return(status: 204, body: '')

      client = described_class.new(headers: headers)
      result = client.make_request('https://api.unsplash.com/photos/123/like', 'DELETE')

      expect(result.status).to eq(204)
    end

    it 'retries on transient network errors' do
      call_count = 0
      stub_request(:get, 'https://api.unsplash.com/photos').to_return do
        call_count += 1
        raise Faraday::ConnectionFailed, 'connection refused' if call_count < 3

        { status: 200, body: '{"id":"retry-ok"}' }
      end

      client = described_class.new(headers: headers, retries: 3, retry_delay_ms: 10)
      result = client.make_request('https://api.unsplash.com/photos', 'GET')

      expect(result.status).to eq(200)
      expect(result.data['id']).to eq('retry-ok')
      expect(call_count).to eq(3)
    end

    it 'does not retry on non-transient HTTP errors' do
      call_count = 0
      stub_request(:get, 'https://api.unsplash.com/photos').to_return do
        call_count += 1
        { status: 500, body: '{"error":"server error"}' }
      end

      client = described_class.new(headers: headers, retries: 3, retry_delay_ms: 10)
      expect { client.make_request('https://api.unsplash.com/photos', 'GET') }.to raise_error(StandardError)

      expect(call_count).to eq(1)
    end

    it 'includes response body in error messages' do
      stub_request(:get, 'https://api.unsplash.com/photos')
        .to_return(status: 422, body: '{"errors":["Invalid parameter"]}')

      client = described_class.new(headers: headers)
      expect { client.make_request('https://api.unsplash.com/photos', 'GET') }
        .to raise_error(StandardError, /HTTP 422.*Invalid parameter/)
    end

    it 'passes query parameters' do
      stub_request(:get, 'https://api.unsplash.com/photos')
        .with(query: { 'page' => '1', 'per_page' => '10' })
        .to_return(status: 200, body: '[]')

      client = described_class.new(headers: headers)
      result = client.make_request('https://api.unsplash.com/photos', 'GET',
                                   query_parameters: { page: 1, per_page: 10 })

      expect(result.status).to eq(200)
    end
  end
end
