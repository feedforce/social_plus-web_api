# -*- encoding: UTF-8 -*-

require 'uri'
require 'net/https'

require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/except'

require 'social_plus/web_api/api_error'

module SocialPlus
  module WebApi
    class Client

      API_KEY_RE = /\A[0-9a-f]{40}\z/
      private_constant :API_KEY_RE

      # @param [String] api_key ソーシャルPLUS APIキー
      def initialize(api_key)
        raise ArgumentError, 'invalid API key' unless API_KEY_RE =~ api_key
        @api_key = api_key.freeze
        freeze
      end

      # ソーシャルPLUS Web APIを実行する
      #
      # @param [String, Symbol] method メソッド名
      # @param [Hash] parameters APIに与えるパラメータ(keyを除く)。 key には自動的にAPIキーが与えられる。
      # @option parameters [Symbol] :via HTTPメソッド(省略時 :get)
      # @return [Hash] APIが返すJSONをパースしたHashからstatusキーを除いたもの。
      #   JSONが解析出来なかった場合は {}
      # @raise [ApiError] API呼び出しが 200 OK 以外の場合
      def execute(method, parameters={})
        parameters = parameters.with_indifferent_access
        http_method = parameters.delete(:via) || :get
        response = request(http_method, method, parameters.merge(key: @api_key))
        result = parse_as_json(response.body)

        case response
        when Net::HTTPOK
          result.except('status')
        when Net::HTTPServerError
          if social_plus_error?(result)
            raise ApiError, result['error']
          else
            raise ApiError, response
          end
        when Net::HTTPClientError
          if social_plus_error?(result)
            raise ApiError, result['error']
          else
            raise ApiError, response
          end
        when Net::HTTPResponse
          raise ApiError, response
        end
      end

      SOCIAL_PLUS_FQDN = URI('https://api.socialplus.jp/')
      private_constant :SOCIAL_PLUS_FQDN

      USER_AGENT = 'Social Campaign'
      private_constant :USER_AGENT

      private

      def request(http_method, api_method, parameters)
        uri = request_uri(api_method)
        request = send("create_#{http_method.downcase}_request", uri, parameters)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
      end

      def create_get_request(uri, parameters)
        Net::HTTP::Get.new(uri.path + '?' + parameters.to_query, 'User-Agent' => USER_AGENT)
      end

      def create_post_request(uri, parameters)
        Net::HTTP::Post.new(uri.path, 'User-Agent' => USER_AGENT).tap { |request| request.body = parameters.to_query }
      end

      def request_uri(method)
        SOCIAL_PLUS_FQDN.dup.tap do |uri|
          uri.path = '/api/%s' % method
        end
      end

      def parse_as_json(json_text)
        json_text ||= '{}'
        JSON.parse(json_text)
      rescue JSON::ParserError
        {}
      end

      def social_plus_error?(result)
        result.key?('error') && %w(message code).all? { |key| result['error'].key?(key) }
      end
    end
  end
end
