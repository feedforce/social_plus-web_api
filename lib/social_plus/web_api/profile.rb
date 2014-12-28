# -*- encoding: UTF-8 -*-

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/conversions'

module SocialPlus
  module WebApi

    # Social Plusから取得したユーザー認証情報のprofile, emailを整理して表現するクラス
    class Profile
      # @param [Hash] params ソーシャルPLUSから取得したユーザー認証情報
      #   以下のキーを参照する。
      # @option params [Hash] "profile" ユーザープロフィール
      # @option params [Array] "email" メールアドレス情報
      def initialize(params)
        @full_name, @given_name, @family_name = '', '', ''
        @full_name_kana, @given_name_kana, @family_name_kana = '', '', ''
        @urls = []
        @zip_code = nil
        @gender = nil
        @birthday = nil
        @emails = []

        params = params.with_indifferent_access

       if params.key?(:profile)
          profile = params[:profile]
          @full_name, @given_name, @family_name, @full_name_kana, @given_name_kana, @family_name_kana = extract_names(profile).freeze

          @zip_code = profile[:postal_code]
          @prefecture, @prefecture_name, @city, @location = extract_location(profile).freeze

          @gender = profile[:gender] if profile[:gender].in?([1, 2])

          if Enumerable === profile[:uri]
            @urls = profile[:uri].map {|uri_string| URI(uri_string).freeze rescue nil}.
              select {|url| url.try(:scheme).in?(['http', 'https'])}.freeze
          end

          if /\A\d{4}-\d{2}-\d{2}\z/ =~ profile[:birthday]
            @birthday = profile[:birthday].try(:to_date).freeze
          end
        end

        if Enumerable === params[:email]
          @emails = params[:email].map {|email| email[:email].freeze}.reject(&:nil?).freeze
        end
        freeze
      end

      # @return [String] 姓名を返す
      attr_reader :full_name

      # @return [String] 姓を返す
      attr_reader :family_name

      # @return [String] 名を返す
      attr_reader :given_name

      # @return [String] 姓名(カナ)を返す
      attr_reader :full_name_kana

      # @return [String] 姓(カナ)を返す
      attr_reader :family_name_kana

      # @return [String] 名(カナ)を返す
      attr_reader :given_name_kana

      # @return [String] 郵便番号を返す
      attr_reader :zip_code

      # @return [Integer] 都道府県コードを返す
      attr_reader :prefecture

      # @return [String] 都道府県名を返す
      attr_reader :prefecture_name

      # @return [Integer] 市区町村コードを返す
      attr_reader :city

      # @return [String] 住所を返す
      attr_reader :location

      # @return [Date] 生年月日を返す
      attr_reader :birthday

      # @return [Array<URI>] URIの配列を返す
      attr_reader :urls

      # @return [Integer] 性別を返す
      attr_reader :gender

      # @return [Array<String>] メールアドレスの配列を返す
      attr_reader :emails

      # @return [HashWithIndifferentAccess] Entryモデルの生成用パラメータを返す
      def to_attributes
        {
          full_name: self.full_name,
          family_name: self.family_name,
          given_name: self.given_name,

          full_name_kana: self.full_name_kana,
          family_name_kana: self.family_name_kana,
          given_name_kana: self.given_name_kana,

          zip_code: self.zip_code,
          prefecture: self.prefecture,
          prefecture_name: self.prefecture_name,
          city: self.city,
          location: self.location,
          birthday: self.birthday,
          gender: self.gender,
          url: self.urls.first,
          email_address: self.emails.first
        }.with_indifferent_access
      end

      private

      # 姓名(full_name), 名(given_name), 姓(family_name), セイメイ(full_name_kana), メイ(given_name_kana), セイ(family_name_kana) の配列を返す。
      def extract_names(profile)
        full_name_kanji = profile[:full_name_kanji] || ''
        last_name_kanji = profile[:last_name_kanji] || ''
        first_name_kanji = profile[:first_name_kanji] || ''

        full_name_kana = profile[:full_name_kana] || ''
        last_name_kana = profile[:last_name_kana] || ''
        first_name_kana = profile[:first_name_kana] || ''

        full_name = profile[:full_name] || ''
        last_name = profile[:last_name] || ''
        first_name = profile[:first_name] || ''
        user_name = profile[:user_name] || ''

        # NOTE: "".present? #=> false

        # *: set
        # -: not set
        #  : no care
        #     full(K) | last(K) | first(K) | full | last | first | user |
        # #1  ******* | ******* | ******** |      |      |       |      |
        # #1  ******* | ******* | -------- |      |      |       |      |
        # #1  ******* | ------- | ******** |      |      |       |      |
        # #1'         |         |          | **** | **** | ***** |      |
        # #1'         |         |          | **** | **** | ----- |      |
        # #1'         |         |          | **** | ---- | ***** |      |
        # #2  ------- | ******* | ******** |      |      |       |      |
        # #2  ------- | ******* | -------- |      |      |       |      |
        # #2  ------- | ------- | ******** |      |      |       |      |
        # #2'         |         |          | ---- | **** | ***** |      |
        # #2'         |         |          | ---- | **** | ----- |      |
        # #2'         |         |          | ---- | ---- | ***** |      |
        # #3  ******* | ------- | -------- |      |      |       |      |
        # #3'         |         |          | **** | ---- | ----- |      |
        # #4  ------- | ------- | -------- | ---- | ---- | ----- | **** |
        # #5  ------- | ------- | -------- | ---- | ---- | ----- | ---- |

        #1
        if full_name_kanji.present? && (last_name_kanji.present? || first_name_kanji.present?)
          names = [ full_name_kanji, first_name_kanji, last_name_kanji ]
        #1'
        elsif full_name.present? && (last_name.present? || first_name.present?)
          names = [ full_name, first_name, last_name ]
        #2
        elsif last_name_kanji.present? || first_name_kanji.present?
          names = [ [last_name_kanji, first_name_kanji].join(' ').strip, first_name_kanji, last_name_kanji ]
        #2'
        elsif last_name.present? || first_name.present?
          names = [ [last_name, first_name].join(' ').strip, first_name, last_name ]
        #3
        elsif full_name_kanji.present?
          names = [ full_name_kanji, '', full_name_kanji ]
        #3'
        elsif full_name.present?
          names = [ full_name, '', full_name ]
        #4
        elsif user_name.present?
          names = [ user_name, '', '' ]
        #5
        else
          names = [ '', '', '' ]
        end

        if full_name_kana.present? && (last_name_kana.present? || first_name_kana.present?)
          kana = [ full_name_kana, first_name_kana, last_name_kana ]
        elsif last_name_kana.present? || first_name_kana.present?
          kana = [ [last_name_kana, first_name_kana].join(' ').strip, first_name_kana, last_name_kana ]
        elsif full_name_kana.present?
          kana = [ full_name_kana, '', full_name_kana ]
        else
          kana = [ '', '', '' ]
        end

        names + kana
      end

      # [ 都道府県コード(prefecture), 都道府県名(prefecture_name), 市区町村コード(city), 都道府県以降の住所(location) ] の配列を返す
      def extract_location(profile)
        city_code = profile[:location_jis_id].to_i
        if city_code > 0
          prefecture_code = city_code / 1000
          if PREFECTURES.key?(prefecture_code)
            prefecture_name = PREFECTURES[prefecture_code]
            location = (profile[:location] || '').sub(/\A#{prefecture_name}/, '')
            [ prefecture_code, prefecture_name, city_code, location ]
          else
            [ nil, '', nil, '' ]
          end
        elsif profile[:location].present?
          [ nil, '', nil, profile[:location] ]
        else
          [ nil, '', nil, '' ]
        end
      end

      PREFECTURES = {
        13 => '東京都'
      }
    end

  end
end
