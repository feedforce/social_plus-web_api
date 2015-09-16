require 'net/http'

# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # An Exception class which wraps errors from SocialPlus Web API
    class ApiError < StandardError

      def self.exception_from_api_result(response, result)
        case response
        when Net::HTTPServerError, Net::HTTPClientError
          if social_plus_error?(result)
            error = result['error']
            case error['code']
            when 4 # WebAPI仕様書参照 TODO: 隠蔽したい
              raise InvalidToken, error
            else
              raise ApiError, error
            end
          else
            raise ApiError, response
          end
        else
          raise ApiError, response
        end
      end

      # @overload initialize(response)
      #   @param response [Net::HTTPResponse] HTTP Response (except 200 OK)
      # @overload initialize(error)
      #   @param error [Hash] a Hash which represents an API error
      #   @option error [String] message the error message
      #   @option error [Integer] code the error code
      def initialize(error)
        case error
        when Net::HTTPResponse
          super(error.message)
          @code = error.code.to_i
        else
          super(error['message'])
          @code = error['code']
        end
      end

      # @return [Integer] the error code (API error code or HTTP status)
      attr_reader :code

      private
      def self.social_plus_error?(result)
        result.key?('error') && %w(message code).all? { |key| result['error'].key?(key) }
      end
    end
  end
end
