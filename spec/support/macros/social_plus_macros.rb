# -*- encoding: UTF-8 -*-

require 'active_support/concern'

module SocialPlusMacros
  extend ActiveSupport::Concern

  included do
    let(:authenticated_user_api_result) {
      {
        'user' => {
          'identifier' => '12345abcde12345abcde12345abcde12345abcde',
          #primary_key
          #mapped_at
          #last_logged_in_at
          'last_logged_in_provider' => 'feedforce',
          #login_count
          #created_at
        },
        'profile' => {
          'first_name' => 'Taro',
          'first_name_kana' => 'タロウ',
          'first_name_kanji' => '太郎',
          #middle_ame
          'last_name' => 'YAMADA',
          'last_name_kana' => 'ヤマダ',
          'last_name_kanji' => '山田',
          'full_name' => 'YAMADA Taro',
          'full_name_kana' => 'ヤマダ タロウ',
          'full_name_kanji' => '山田 太郎',
          'user_name' => 'taro',
          #verified
          'gender' => 1,
          #blood_type
          'birthday' => '1990-01-01',
          #relationship_status
          'location' => '東京都文京区1-2-1',
          #location_id
          'location_jis_id' => 13106,
          'postal_code' => '112-0002',
          #hometown
          #hometown_id
          #hometown_jis_id
          #graduated_school
          #graduated_school_type
          #job_company
          #job_position
          'uri' => %w(http://example.com),
          #website
          #quotes
          #bio
          #imaage_url
          #last_updated_at
        },
        'follow' => {
          'following' => 100,
          'followed_by' => 200
        },
        'email' => [
          { 'email' => 'taro-facebook@example.com', 'verified' => true, 'media_id' => 'facebook' },
          { 'email' => 'taro-twitter@example.com', 'verified' => true, 'media_id' => 'twitter' }
        ]
      }
    }
    let(:providers_of_user_api_result) {
      { 'providers' => %w(facebook twitter) }
    }
    let(:social_plus_user_params) {
      authenticated_user_api_result.merge(providers_of_user_api_result)
    }
  end
end
