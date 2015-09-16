require 'net/http'

# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # An Exception class which wraps errors from SocialPlus Web API
    class ApiError < StandardError
      # @overload initialize(response)
      #   @param response [Net::HTTPResponse] HTTP Response (except 200 OK)
      # @overload initialize(error)
      #   @param error [Hash] a Hash which represents an API error
      #   @option error [String] message the error message
      #   @option error [Integer] code the error code
      def initialize(error)
        super(error['message'])
        @code = error['code']
      end

      # @return [Integer] the error code (API error code or HTTP status)
      attr_reader :code
    end

    require 'social_plus/web_api/invalid_token'
    require 'social_plus/web_api/http_responce_error'

    class ApiError < StandardError
      EXCEPTION_CLASSES = Hash.new(ApiError).tap do |exception_classes|
        exception_classes[4] = InvalidToken
      end

      def self.exception_from_api_result(response, result)
        if social_plus_error?(response, result)
          error = result['error']
          raise EXCEPTION_CLASSES[error['code']], error
        else
          raise HttpResponceError, response
        end
      end

      private
      def self.social_plus_error?(response, result)
        case response
        when Net::HTTPServerError, Net::HTTPClientError
          result.key?('error') && %w(message code).all? { |key| result['error'].key?(key) }
        else
          false
        end
      end
    end
  end
end
