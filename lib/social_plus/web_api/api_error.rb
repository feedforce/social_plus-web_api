# -*- encoding: UTF-8 -*-

require 'net/http'

module SocialPlus
  module WebApi

    # SocialPlus APIのエラーレスポンスボディをラップする例外
    class ApiError < StandardError
      # @overload initialize(response)
      #   @param response [Net::HTTPResponse] HTTPレスポンス(OK以外)
      # @overload initialize(error)
      #   @param error [Hash] エラーを表すHash
      #   @option error [String] message エラーメッセージ
      #   @option error [Integer] code エラーコード
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

      # @return [Integer] エラーコード(APIエラーコード または HTTPステータスコード)
      attr_reader :code
    end

  end
end
