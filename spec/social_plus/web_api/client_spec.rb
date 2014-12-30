# -*- encoding: UTF-8 -*-

require 'json'
require 'social_plus/web_api/client'

describe SocialPlus::WebApi::Client do
  describe '#initialize' do
    context '書式が妥当なAPIキー' do
      # 40-digit hexadecimal
      let(:valid_api_key) { '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }
      let(:client) { SocialPlus::WebApi::Client.new(valid_api_key) }
      it { expect(client).to be_an_instance_of(SocialPlus::WebApi::Client) }
    end

    context '書式が妥当でないAPIキー' do
      let(:invalid_api_key) { '100e1d1' }
      let(:client) { SocialPlus::WebApi::Client.new(invalid_api_key) }
      it { expect { client }.to raise_error(ArgumentError) }
    end
  end

  shared_examples_for 'Web API' do
    context '登録済みのAPIキー' do
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

    context '未登録のAPIキー' do
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
      it 'API例外を発生させる' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.message).to eq('Invalid API key or API key not found.')
          expect(error.code).to eq(1)
        }
      end
    end

    context 'APIと無関係なサーバーエラーが発生' do
      let(:stub_status) { 503 }
      let(:stub_body) { '' }
      it 'HTTP応答に基づいたAPI例外を発生させる' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(503)
        }
      end
    end

    context 'APIと無関係なクライアントエラーが発生' do
      let(:stub_status) { 402 }
      let(:stub_body) { '' }
      it 'HTTP応答に基づいたAPI例外を発生させる' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(402)
        }
      end
    end

    context 'APIの応答でもHTTPエラーでもない' do
      let(:stub_status) { 301 }
      let(:stub_body) { '' }
      it 'HTTP応答に基づいたAPI例外を発生させる' do
        expect { api_call }.to raise_error {|error|
          expect(error).to be_an_instance_of(SocialPlus::WebApi::ApiError)
          expect(error.code).to eq(301)
        }
      end
    end
  end

  let(:api_key) { '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }
  let(:client) { SocialPlus::WebApi::Client.new(api_key) }

  describe 'GET リクエスト' do
    describe 'リクエストヘッダー' do
      let(:request) { client.send(:create_get_request, 'appinfo', key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3') }
      describe 'User-Agent' do
        it { expect(request['User-Agent']).to eq('Social Campaign') }
      end
    end

    describe 'API呼び出し' do
      let(:api_call) { client.execute('appinfo', {}) }
      before :each do
        stub_request(:get, 'https://api.socialplus.jp/api/appinfo').with(query: { key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }).to_return(
          status: stub_status, body: stub_body
        )
      end

      it_behaves_like 'Web API'
    end
  end

  describe 'POST リクエスト' do
    describe 'リクエストヘッダー' do
      let(:request) { client.send(:create_post_request, 'share', key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3') }
      describe 'User-Agent' do
        it { expect(request['User-Agent']).to eq('Social Campaign') }
      end
    end

    describe 'API呼び出し' do
      let(:api_call) { client.execute('share', via: :post) }
      before :each do
        stub_request(:post, 'https://api.socialplus.jp/api/share').with(body: { key: '100e1d1f03d1cbcbd35d1a07dcafa96b364c67d3' }).to_return(
          status: stub_status, body: stub_body
        )
      end

      it_behaves_like 'Web API'
    end
  end
end
