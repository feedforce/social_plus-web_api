require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/conversions'

require 'social_plus/web_api/prefectures'

# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # rubocop: disable Metrics/ClassLength, Metrics/AbcSize

    # A class which represents authenticated user's information(profile and email) obtained from Social Plus
    class Profile
      # rubocop: disable Metrics/MethodLength

      # @param [Hash<String,Object>] params a user's information obtained from Social Plus.
      # @option params [Hash] "profile" profile of a user
      # @option params [Array] "email" email addresses of a user

      def initialize(params)
        params = params.with_indifferent_access

        profile = params[:profile]
        @full_name, @given_name, @family_name, @full_name_kana, @given_name_kana, @family_name_kana = extract_names(profile).freeze
        @zip_code = profile[:postal_code]
        @prefecture, @prefecture_name, @city, @location = extract_location(profile).freeze
        @gender = profile[:gender].in?([1, 2]) ? profile[:gender] : nil
        @urls = profile[:uri].respond_to?(:map) ? filter_http_urls(profile[:uri]) : []
        @birthday = /\A\d{4}-\d{2}-\d{2}\z/ =~ profile[:birthday] ? profile[:birthday].try(:to_date).freeze : nil

        emails = params[:email]
        @emails = emails && emails.respond_to?(:map) ? emails.map { |email| email[:email].freeze }.compact.freeze : []

        freeze
      end
      # rubocop: enable Metrics/MethodLength

      # @return [String] Returns the user's full name
      attr_reader :full_name

      # @return [String] Returns the user's family name
      attr_reader :family_name

      # @return [String] Returns the user's given name
      attr_reader :given_name

      # @return [String] Returns the user's full name in kana
      attr_reader :full_name_kana

      # @return [String] Returns the user's family name in kana
      attr_reader :family_name_kana

      # @return [String] Returns the user's given name in kana
      attr_reader :given_name_kana

      # @return [String] Returns the zip code of user's address
      attr_reader :zip_code

      # @return [Integer] Returns the prefecture code of user's address
      attr_reader :prefecture

      # @return [String] Returns the name of prefecture of user's address
      attr_reader :prefecture_name

      # @return [Integer] Returns the city code of user's address
      attr_reader :city

      # @return [String] Returns the rest of user's address
      attr_reader :location

      # @return [Date] Returns the user's birthday
      attr_reader :birthday

      # @return [Array<URI>] Returns the user's URLs
      attr_reader :urls

      # @return [Integer] Returns the user's gender
      attr_reader :gender

      # @return [Array<String>] Returns the user's E-Mail addresses
      attr_reader :emails

      private

      def filter_http_urls(uris)
        uris.map { |uri_string| URI(uri_string).freeze rescue nil }.select { |url| url.try(:scheme).in?(%w(http https)) }.freeze
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

      # @return [Array] Returns Array of full name, given name, family name, full name in kana, given name in kana and family name in kana
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
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

      # @return [Array] Returns prefecture code, prefecture_name, city code and location(rest of the address)
      def extract_location(profile)
        location = profile[:location].presence || ''

        city_code = city_code(profile)
        prefecture_code = city_code ? city_code_to_prefecture_code(city_code) : nil
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
    end
    # rubocop: enable Metrics/ClassLength
  end
end
