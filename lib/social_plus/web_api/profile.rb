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
        params = params.with_indifferent_access
        assign_profile(params[:profile]) if params.key?(:profile)

        @emails = []
        assign_emails(params[:email]) if params.key?(:email) && params[:email].respond_to?(:map)
        freeze
      end

      def assign_profile(profile)
        assign_names(profile)
        @zip_code = profile[:postal_code]
        assign_location(profile)
        @gender = profile[:gender] if profile[:gender].in?([1, 2])
        @urls = profile[:uri].respond_to?(:map) ? filter_http_urls(profile[:uri]) : []
        @birthday = /\A\d{4}-\d{2}-\d{2}\z/ =~ profile[:birthday] ? profile[:birthday].try(:to_date).freeze : nil
      end

      def filter_http_urls(uris)
        uris.map { |uri_string| URI(uri_string).freeze rescue nil }.select { |url| url.try(:scheme).in?(%w(http https)) }
      end

      def assign_location(profile)
        @prefecture, @prefecture_name, @city, @location = extract_location(profile).freeze
      end

      def assign_names(profile)
        @full_name, @given_name, @family_name, @full_name_kana, @given_name_kana, @family_name_kana = extract_names(profile).freeze
      end

      def assign_emails(emails)
        @emails = emails.map { |email| email[:email].freeze }.reject(&:nil?).freeze
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

      ATTRIBUTE_KEYS = %w(
        full_name      family_name      given_name
        full_name_kana family_name_kana given_name_kana
        zip_code prefecture prefecture_name city location
        birthday
        gender
      )

      # @return [HashWithIndifferentAccess] Entryモデルの生成用パラメータを返す
      def to_attributes
        {}.with_indifferent_access.tap do |attributes|
          ATTRIBUTE_KEYS.each { |key| attributes[key] = send(key) }
          attributes[:url] = urls.first
          attributes[:email] = emails.first
        end
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

        # #1
        if full_name_kanji.present? && (last_name_kanji.present? || first_name_kanji.present?)
          names = [ full_name_kanji, first_name_kanji, last_name_kanji ]
        # #1'
        elsif full_name.present? && (last_name.present? || first_name.present?)
          names = [ full_name, first_name, last_name ]
        # #2
        elsif last_name_kanji.present? || first_name_kanji.present?
          names = [ [last_name_kanji, first_name_kanji].join(' ').strip, first_name_kanji, last_name_kanji ]
        # #2'
        elsif last_name.present? || first_name.present?
          names = [ [last_name, first_name].join(' ').strip, first_name, last_name ]
        # #3
        elsif full_name_kanji.present?
          names = [ full_name_kanji, '', full_name_kanji ]
        # #3'
        elsif full_name.present?
          names = [ full_name, '', full_name ]
        # #4
        elsif user_name.present?
          names = [ user_name, '', '' ]
        # #5
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
        location = profile[:location].presence || ''

        city_code = city_code(profile)
        prefecture_code = city_code_to_prefecture_code(city_code) if city_code
        return [ nil, '', nil, location ] unless city_code && prefecture_code

        prefecture_name = PREFECTURES[prefecture_code]
        location_without_prefecture = location.sub(/\A#{prefecture_name}/, '')
        [ prefecture_code, prefecture_name, city_code, location_without_prefecture ]
      end

      def city_code(profile)
        profile[:location_jis_id].to_i.presence
      end

      def city_code_to_prefecture_code(city_code)
        code = city_code / 1000
        PREFECTURES.key?(code) ? code : nil
      end

      PREFECTURES = {
        1 => '北海道',
        2 => '青森県',
        3 => '岩手県',
        4 => '宮城県',
        5 => '秋田県',
        6 => '山形県',
        7 => '福島県',
        8 => '茨城県',
        9 => '栃木県',
        10 => '群馬県',
        11 => '埼玉県',
        12 => '千葉県',
        13 => '東京都',
        14 => '神奈川県',
        15 => '新潟県',
        16 => '富山県',
        17 => '石川県',
        18 => '福井県',
        19 => '山梨県',
        20 => '長野県',
        21 => '岐阜県',
        22 => '静岡県',
        23 => '愛知県',
        24 => '三重県',
        25 => '滋賀県',
        26 => '京都府',
        27 => '大阪府',
        28 => '兵庫県',
        29 => '奈良県',
        30 => '和歌山県',
        31 => '鳥取県',
        32 => '島根県',
        33 => '岡山県',
        34 => '広島県',
        35 => '山口県',
        36 => '徳島県',
        37 => '香川県',
        38 => '愛媛県',
        39 => '高知県',
        40 => '福岡県',
        41 => '佐賀県',
        42 => '長崎県',
        43 => '熊本県',
        44 => '大分県',
        45 => '宮崎県',
        46 => '鹿児島県',
        47 => '沖縄県'
      }
    end
  end
end
