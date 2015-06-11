require 'json'
require 'uri'
require 'net/https'

require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/except'

require 'social_plus/web_api/api_error'
require 'social_plus/web_api/version'

# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # A class which wraps calls to Social Plus Web API
    class Client
      API_KEY_RE = /\A[0-9a-f]{40}\z/
      private_constant :API_KEY_RE

      # @param [String] api_key A Social Plus API key
      # @raise [ArgumentError] when `api_key` is invalid
      def initialize(api_key)
        raise ArgumentError, 'invalid API key' unless API_KEY_RE =~ api_key
        @api_key = api_key.freeze
        freeze
      end

      # Executes a Social Plus Web API
      #
      # @param [String, Symbol] method An API method name
      # @param [Hash] parameters Parameters to API except `key`
      # @option parameters [Symbol] :via HTTP method(default `:get`)
      # @return [Hash] a Hash generated by parsing the JSON returned from the API call, except `status`,
      #   just `{}` on parsing failure
      # @raise [ApiError] when the API returns a status other than 200 OK
      def execute(method, parameters={})
        parameters = parameters.with_indifferent_access
        http_method = parameters.delete(:via) || :get
        response = request(http_method, method, parameters.merge(key: @api_key))
        result = parse_as_json(response.body)

        raise_api_error(response, result) unless response.is_a?(Net::HTTPOK)

        result.except('status')
      end

      def raise_api_error(response, result)
        case response
        when Net::HTTPServerError, Net::HTTPClientError
          if social_plus_error?(result)
            raise ApiError, result['error']
          else
            raise ApiError, response
          end
        else
          raise ApiError, response
        end
      end

      SOCIAL_PLUS_FQDN = URI('https://api.socialplus.jp/')
      private_constant :SOCIAL_PLUS_FQDN

      USER_AGENT = 'Social Campaign/%s' % VERSION
      private_constant :USER_AGENT

      private

      def request(http_method, api_method, parameters)
        uri = request_uri(api_method)
        request = send("create_#{http_method.downcase}_request", uri.path, parameters)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
      end

      def create_get_request(path, parameters)
        Net::HTTP::Get.new(path + '?' + parameters.to_query, 'User-Agent' => USER_AGENT)
      end

      def create_post_request(path, parameters)
        Net::HTTP::Post.new(path, 'User-Agent' => USER_AGENT).tap { |request| request.body = parameters.to_query }
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
