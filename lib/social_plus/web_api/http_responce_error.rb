# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # An Exception class raised when SocialPlus Web API reports http response error
    #
    class HttpResponceError < ApiError
      # @overload initialize(response)
      #   @param response [Net::HTTPResponse] HTTP Response (except 200 OK)
      def initialize(response)
        super(
          'message' => response.message,
          'code'    => response.code.to_i
        )
      end
    end
  end
end
