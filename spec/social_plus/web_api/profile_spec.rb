# -*- encoding: UTF-8 -*-

require 'social_plus/web_api/profile'

describe SocialPlus::WebApi::Profile do
  include SocialPlusMacros
  let(:params) { social_plus_user_params }

  describe '#initialize' do
    subject { described_class.new(params) }

    describe 'name stuff' do
      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ******* | ******** |      |      |       |      |
      its(:full_name) { should eq('山田 太郎') }
      its(:family_name) { should eq('山田') }
      its(:given_name) { should eq('太郎') }

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ******* | -------- |      |      |       |      |
      context %q|with 'full_name_kanji', 'last_name_kanji'| do
        before do
          params['profile'].except!('first_name_kanji')
        end
        its(:full_name) { should eq('山田 太郎') }
        its(:family_name) { should eq('山田') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ------- | ******** |      |      |       |      |
      context %q|with 'full_name_kanji', 'first_name_kanji'| do
        before do
          params['profile'].except!('last_name_kanji')
        end
        its(:full_name) { should eq('山田 太郎') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | **** | ***** |      |
      context %q|with 'full_name', 'last_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
        end
        its(:full_name) { should eq('YAMADA Taro') }
        its(:family_name) { should eq('YAMADA') }
        its(:given_name) { should eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | **** | ----- |      |
      context %q|with 'full_name', 'last_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('first_name')
        end
        its(:full_name) { should eq('YAMADA Taro') }
        its(:family_name) { should eq('YAMADA') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | ---- | ***** |      |
      context %q|with 'full_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('last_name')
        end
        its(:full_name) { should eq('YAMADA Taro') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ******* | ******** |      |      |       |      |
      context %q|with 'last_name_kanji', 'first_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        its(:full_name) { should eq('山田 太郎') }
        its(:family_name) { should eq('山田') }
        its(:given_name) { should eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ******* | -------- |      |      |       |      |
      context %q|with 'last_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        its(:full_name) { should eq('山田') }
        its(:family_name) { should eq('山田') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ------- | ******** |      |      |       |      |
      context %q|with 'first_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        its(:full_name) { should eq('太郎') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | **** | ***** |      |
      context %q|with 'last_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name')
        end
        its(:full_name) { should eq('YAMADA Taro') }
        its(:family_name) { should eq('YAMADA') }
        its(:given_name) { should eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | **** | ----- |      |
      context %q|with 'last_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'first_name')
        end
        its(:full_name) { should eq('YAMADA') }
        its(:family_name) { should eq('YAMADA') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | ---- | ***** |      |
      context %q|with 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name')
        end
        its(:full_name) { should eq('Taro') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #3  ******* | ------- | -------- |      |      |       |      |
      context %q|with 'full_name_kanji'| do
        before do
          params['profile'].except!('last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        its(:full_name) { should eq('山田 太郎') }
        its(:family_name) { should eq('山田 太郎') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #3'         |         |          | **** | ---- | ----- |      |
      context %q|with 'full_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('last_name', 'first_name')
        end
        its(:full_name) { should eq('YAMADA Taro') }
        its(:family_name) { should eq('YAMADA Taro') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #4  ------- | ------- | -------- | ---- | ---- | ----- | **** |
      context %q|with only 'user_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        its(:full_name) { should eq('taro') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #5  ------- | ------- | -------- | ---- | ---- | ----- | ---- |
      context %q|with nothing| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
          params['profile'].except!('user_name')
        end
        its(:full_name) { should eq('') }
        its(:family_name) { should eq('') }
        its(:given_name) { should eq('') }
      end
    end

    describe 'kana stuff' do
      #     full(K) | last(K) | first(K) |
      # #1  ******* | ******* | ******** |
      its(:full_name_kana) { should eq('ヤマダ タロウ') }
      its(:family_name_kana) { should eq('ヤマダ') }
      its(:given_name_kana) { should eq('タロウ') }

      #     full(K) | last(K) | first(K) |
      # #1  ******* | ******* | -------- |
      context %q|with 'full_name_kana', 'last_name_kana'| do
        before do
          params['profile'].except!('first_name_kana')
        end
        its(:full_name_kana) { should eq('ヤマダ タロウ') }
        its(:family_name_kana) { should eq('ヤマダ') }
        its(:given_name_kana) { should eq('') }
      end

      #     full(K) | last(K) | first(K) |
      # #1  ******* | ------- | ******** |
      context %q|with 'full_name_kana', 'first_name_kana'| do
        before do
          params['profile'].except!('last_name_kana')
        end
        its(:full_name_kana) { should eq('ヤマダ タロウ') }
        its(:family_name_kana) { should eq('') }
        its(:given_name_kana) { should eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ******* | ******** |
      context %q|with 'last_name_kana', 'first_name_kana'| do
        before do
          params['profile'].except!('full_name_kana')
        end
        its(:full_name_kana) { should eq('ヤマダ タロウ') }
        its(:family_name_kana) { should eq('ヤマダ') }
        its(:given_name_kana) { should eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ******* | -------- |
      context %q|with 'last_name_kana'| do
        before do
          params['profile'].except!('full_name_kana', 'first_name_kana')
        end
        its(:full_name_kana) { should eq('ヤマダ') }
        its(:family_name_kana) { should eq('ヤマダ') }
        its(:given_name_kana) { should eq('') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ------- | ******** |
      context %q|with 'first_name_kana'| do
        before do
          params['profile'].except!('full_name_kana', 'last_name_kana')
        end
        its(:full_name_kana) { should eq('タロウ') }
        its(:family_name_kana) { should eq('') }
        its(:given_name_kana) { should eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #3  ******* | ------- | -------- |
      context %q|with 'full_name_kana'| do
        before do
          params['profile'].except!('last_name_kana', 'first_name_kana')
        end
        its(:full_name_kana) { should eq('ヤマダ タロウ') }
        its(:family_name_kana) { should eq('ヤマダ タロウ') }
        its(:given_name_kana) { should eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #5  ------- | ------- | -------- | ---- | ---- | ----- | ---- |
      context %q|with nothing| do
        before do
          params['profile'].except!('full_name_kana', 'last_name_kana', 'first_name_kana')
        end
        its(:full_name_kana) { should eq('') }
        its(:family_name_kana) { should eq('') }
        its(:given_name_kana) { should eq('') }
      end
    end

    describe '#zip_code' do
      its(:zip_code) { should eq('112-0002') }
      context %q|when 'postal_code' is missing| do
        before do
          params['profile'].except!('postal_code')
        end
        its(:zip_code) { should be_nil }
      end
    end

    describe 'location stuff' do
      its(:prefecture) { should eq(13) }
      its(:prefecture_name) { should eq('東京都') }
      its(:city) { should eq(13106) }
      its(:location) { should eq('文京区1-2-1') }

      context %q|'location_jis_id' is out of range| do
        before do
          params['profile']['location_jis_id'] = 50101
        end
        its(:prefecture) { should be_nil }
        its(:prefecture_name) { should eq('') }
        its(:city) { should be_nil }
        its(:location) { should eq('') }
      end

      context %q|'location_jis_id' is missing| do
        before do
          params['profile'].except!('location_jis_id')
        end
        its(:prefecture) { should be_nil }
        its(:prefecture_name) { should eq('') }
        its(:city) { should be_nil }
        its(:location) { should eq('東京都文京区1-2-1') }
      end

      context %q|'location_jis_id' and 'location' are missing| do
        before do
          params['profile'].except!('location_jis_id', 'location')
        end
        its(:prefecture) { should be_nil }
        its(:prefecture_name) { should eq('') }
        its(:city) { should be_nil }
        its(:location) { should eq('') }
      end
    end

    describe 'birthday' do
      its(:birthday) { should eq(Date.parse('1990-1-1')) }

      context %q|when 'birthday' is missing| do
        before do
          params['profile'].except!('birthday')
        end
        its(:birthday) { should be_nil }
      end

      context %q|when 'birthday' is invalid| do
        before do
          params['profile']['birthday'] = '-1990-1-1'
        end
        its(:birthday) { should be_nil }
      end
    end

    describe 'gender' do
      its(:gender) { should eq(1) }

      context %q|when 'gender' is missing| do
        before do
          params['profile'].except!('gender')
        end
        its(:gender) { should be_nil }
      end

      context %q|when 'gender' is invalid| do
        before do
          params['profile']['gender'] = 99
        end
        its(:gender) { should be_nil }
      end
    end

    describe 'urls' do
      its(:urls) { should eq([ URI('http://example.com') ]) }

      context %q|when 'uri' is missing| do
        before do
          params['profile'].except!('uri')
        end
        its(:urls) { should eq([]) }
      end

      context %q|when 'uri' is empty| do
        before do
          params['profile']['uri'] = []
        end
        its(:urls) { should eq([]) }
      end

      context %q|when 'uri' is invalid| do
        before do
          params['profile']['uri'] = [ '-http://example.com' ]
        end
        its(:urls) { should eq([]) }
      end
      context %q|when scheme of 'uri' is invalid| do
        before do
          params['profile']['uri'] = [ 'ftp://example.com' ]
        end
        its(:urls) { should eq([]) }
      end
    end
    describe 'email' do
      its(:emails) { should eq(['taro-facebook@example.com', 'taro-twitter@example.com']) }

      context %q|when 'email' is missing| do
        before do
          params.except!('email')
        end
        its(:emails) { should eq([]) }
      end
      context %q|when 'email' is empty| do
        before do
          params['email'] = []
        end
        its(:emails) { should eq([]) }
      end
      context %q|when 'email[0]/email' is missing| do
        before do
          params['email'][0]['email'] = nil
        end
        its(:emails) { should eq(['taro-twitter@example.com']) }
      end
    end
  end
end
