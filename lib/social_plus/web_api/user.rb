# -*- encoding: UTF-8 -*-

require 'social_plus/web_api/profile'
require 'active_support/core_ext/string/inquiry'
require 'active_support/core_ext/hash/slice'

module SocialPlus
  module WebApi
    # ソーシャルPLUS上のユーザーを表すオブジェクト
    class User
      TOKEN_RE = /\A[0-9a-f]{40}\z/
      private_constant :TOKEN_RE

      class << self
        # トークンを用いてユーザー情報を取得する
        # @param [Client] api_client APIクライアント
        # @param [String] token ソーシャルログインのコールバックで渡されたトークン
        # @return [User] ユーザーオブジェクト
        def authenticate(api_client, token)
          raise ArgumentError, 'invalid token' unless TOKEN_RE =~ token
          result = api_client.execute('authenticated_user', token: token, add_profile: true)
          result['providers'] = api_client.execute('providers_of_user', identifier: result['user']['identifier'])['providers']
          new(result)
        end
        private :new
      end

      # @param {hash] params ソーシャルAPIから取得したユーザー情報
      # @option params [Hash] "user" ユーザー
      # @option params [Hash] "profile" ユーザーのプロフィール情報
      # @option params [Array] "email" ユーザーのメールアドレス情報
      # @option params [Hash] "follow" ユーザーのフォロー/被フォロー状況
      # @option params [Hash] "providers" ログインしたことのあるプロバイダ
      def initialize(params)
        raise ArgumentError, %q|missing 'user'| unless params.key?('user')
        user = params['user']
        raise ArgumentError, %q|missing 'user/identifier'| unless user.key?('identifier')

        @identifier = user['identifier']
        last_logged_in_provider = user['last_logged_in_provider'] || ''
        @last_logged_in_provider = last_logged_in_provider.inquiry.freeze
        @profile = SocialPlus::WebApi::Profile.new(params.slice('profile', 'email')).freeze
        @followers = params.key?('follow') && params['follow'].key?('followed_by') ? params['follow']['followed_by'] : 0
        @providers = params['providers']
      end

      # @return [String] ソーシャルPLUS IDを返す
      attr_reader :identifier
      # @return [String] 最後にログインしたプロバイダ名を返す
      attr_reader :last_logged_in_provider
      # @return [Profile] プロフィールオブジェクトを返す
      attr_reader :profile
      # @return [Integer] フォロワー数(リーチ数)を返す
      attr_reader :followers
      # @return [Array] ログインしたことのあるプロバイダ名の配列を返す
      attr_reader :providers
    end
  end
end
