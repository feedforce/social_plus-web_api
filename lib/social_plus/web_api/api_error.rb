require 'net/http'

module SocialPlus
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
    end
  end
end
