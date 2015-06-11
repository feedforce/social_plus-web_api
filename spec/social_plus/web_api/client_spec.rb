require 'social_plus/web_api/client'

describe SocialPlus::WebApi::Client do
  describe '#initialize' do
    let(:clinet) { SocialPlus::WebApi::Client.new(api_key) }
    context 'with valid API key' do
      # 40-digit hexadecimal
      let(:api_key) { '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }
      it { expect(client).to be_an_instance_of(SocialPlus::WebApi::Client) }
    end

    context 'with invalid API key' do
      let(:api_key) { '100e1d1' }
      it { expect { client }.to raise_error(ArgumentError) }
    end
  end

  shared_examples_for 'Web API' do
    context 'with registered API key' do
      let(:stub_status) { 200 }
      let(:stub_body) {
        {
          'status' => 'ok',
          'info' => {
            'account' => 'ff',
            'site_id' => 'demoapp'
          }
        }.to_json
      }
      it { expect(api_call).to eq('info' => { 'account' => 'ff', 'site_id' => 'demoapp' }) }
    end

    context 'with unregistered API key' do
      let(:stub_status) { 400 }
      let(:stub_body) {
        {
          'status' => 'failed',
          'error' => {
            'code' => 1,
            'message' => 'Invalid API key or API key not found.'
          }
        }.to_json
      }
      it 'raises an ApiError' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.message).to eq('Invalid API key or API key not found.')
          expect(error.code).to eq(1)
        }
      end
    end

    context 'when a server error unrelated to the API occurs' do
      let(:stub_status) { 503 }
      let(:stub_body) { '' }
      it 'raises an ApiError based on the HTTP response' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(503)
        }
      end
    end

    context 'when a client error unrelated to the API occurs' do
      let(:stub_status) { 402 }
      let(:stub_body) { '' }
      it 'raises an ApiError based on the HTTP response' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(402)
        }
      end
    end

    context 'when the response is neither an API response nor an HTTP error' do
      let(:stub_status) { 301 }
      let(:stub_body) { '' }
      it 'raises an ApiError based on the HTTP response' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(301)
        }
      end
    end
  end

  let(:api_key) { '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }
  let(:client) { SocialPlus::WebApi::Client.new(api_key) }

  describe 'GET request' do
    describe 'request headers' do
      let(:request) { client.send(:create_get_request, 'appinfo', key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3') }
      describe 'User-Agent' do
        it { expect(request['User-Agent']).to eq('SocialPlus Web API gem/0.0.1') }
      end
    end

    describe 'an API call' do
      let(:api_call) { client.execute('appinfo', {}) }
      before :each do
        stub_request(:get, 'https://api.socialplus.jp/api/appinfo').with(query: { key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }).to_return(
          status: stub_status, body: stub_body
        )
      end

      it_behaves_like 'Web API'
    end
  end

  describe 'POST request' do
    describe 'request headers' do
      let(:request) { client.send(:create_post_request, 'share', key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3') }
      describe 'User-Agent' do
        it { expect(request['User-Agent']).to eq('SocialPlus Web API gem/0.0.1') }
      end
    end

    describe 'an API call' do
      let(:api_call) { client.execute('share', via: :post) }
      before :each do
        stub_request(:post, 'https://api.socialplus.jp/api/share').with(body: 'key=100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3').to_return(
          status: stub_status, body: stub_body
        )
      end

      it_behaves_like 'Web API'
    end
  end
end
