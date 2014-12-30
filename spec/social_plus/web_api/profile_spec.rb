# -*- encoding: UTF-8 -*-

require 'support/macros/social_plus_macros'
require 'social_plus/web_api/profile'

describe SocialPlus::WebApi::Profile do
  include SocialPlusMacros
  let(:params) { social_plus_user_params }

  describe '#initialize' do
    let(:profile) { SocialPlus::WebApi::Profile.new(params) }

    describe 'name stuff' do
      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ******* | ******** |      |      |       |      |
      it { expect(profile.full_name).to eq('山田 太郎') }
      it { expect(profile.family_name).to eq('山田') }
      it { expect(profile.given_name).to eq('太郎') }

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ******* | -------- |      |      |       |      |
      context %q|with 'full_name_kanji', 'last_name_kanji'| do
        before do
          params['profile'].except!('first_name_kanji')
        end
        it { expect(profile.full_name).to eq('山田 太郎') }
        it { expect(profile.family_name).to eq('山田') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1  ******* | ------- | ******** |      |      |       |      |
      context %q|with 'full_name_kanji', 'first_name_kanji'| do
        before do
          params['profile'].except!('last_name_kanji')
        end
        it { expect(profile.full_name).to eq('山田 太郎') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | **** | ***** |      |
      context %q|with 'full_name', 'last_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
        end
        it { expect(profile.full_name).to eq('YAMADA Taro') }
        it { expect(profile.family_name).to eq('YAMADA') }
        it { expect(profile.given_name).to eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | **** | ----- |      |
      context %q|with 'full_name', 'last_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('first_name')
        end
        it { expect(profile.full_name).to eq('YAMADA Taro') }
        it { expect(profile.family_name).to eq('YAMADA') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #1'         |         |          | **** | ---- | ***** |      |
      context %q|with 'full_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('last_name')
        end
        it { expect(profile.full_name).to eq('YAMADA Taro') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ******* | ******** |      |      |       |      |
      context %q|with 'last_name_kanji', 'first_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('山田 太郎') }
        it { expect(profile.family_name).to eq('山田') }
        it { expect(profile.given_name).to eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ******* | -------- |      |      |       |      |
      context %q|with 'last_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('山田') }
        it { expect(profile.family_name).to eq('山田') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2  ------- | ------- | ******** |      |      |       |      |
      context %q|with 'first_name_kanji'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('太郎') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('太郎') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | **** | ***** |      |
      context %q|with 'last_name', 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name')
        end
        it { expect(profile.full_name).to eq('YAMADA Taro') }
        it { expect(profile.family_name).to eq('YAMADA') }
        it { expect(profile.given_name).to eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | **** | ----- |      |
      context %q|with 'last_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('YAMADA') }
        it { expect(profile.family_name).to eq('YAMADA') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #2'         |         |          | ---- | ---- | ***** |      |
      context %q|with 'first_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name')
        end
        it { expect(profile.full_name).to eq('Taro') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('Taro') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #3  ******* | ------- | -------- |      |      |       |      |
      context %q|with 'full_name_kanji'| do
        before do
          params['profile'].except!('last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('山田 太郎') }
        it { expect(profile.family_name).to eq('山田 太郎') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #3'         |         |          | **** | ---- | ----- |      |
      context %q|with 'full_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('YAMADA Taro') }
        it { expect(profile.family_name).to eq('YAMADA Taro') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #4  ------- | ------- | -------- | ---- | ---- | ----- | **** |
      context %q|with only 'user_name'| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
        end
        it { expect(profile.full_name).to eq('taro') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #5  ------- | ------- | -------- | ---- | ---- | ----- | ---- |
      context %q|with nothing| do
        before do
          params['profile'].except!('full_name_kanji', 'last_name_kanji', 'first_name_kanji')
          params['profile'].except!('full_name', 'last_name', 'first_name')
          params['profile'].except!('user_name')
        end
        it { expect(profile.full_name).to eq('') }
        it { expect(profile.family_name).to eq('') }
        it { expect(profile.given_name).to eq('') }
      end
    end

    describe 'kana stuff' do
      #     full(K) | last(K) | first(K) |
      # #1  ******* | ******* | ******** |
      it { expect(profile.full_name_kana).to eq('ヤマダ タロウ') }
      it { expect(profile.family_name_kana).to eq('ヤマダ') }
      it { expect(profile.given_name_kana).to eq('タロウ') }

      #     full(K) | last(K) | first(K) |
      # #1  ******* | ******* | -------- |
      context %q|with 'full_name_kana', 'last_name_kana'| do
        before do
          params['profile'].except!('first_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('ヤマダ タロウ') }
        it { expect(profile.family_name_kana).to eq('ヤマダ') }
        it { expect(profile.given_name_kana).to eq('') }
      end

      #     full(K) | last(K) | first(K) |
      # #1  ******* | ------- | ******** |
      context %q|with 'full_name_kana', 'first_name_kana'| do
        before do
          params['profile'].except!('last_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('ヤマダ タロウ') }
        it { expect(profile.family_name_kana).to eq('') }
        it { expect(profile.given_name_kana).to eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ******* | ******** |
      context %q|with 'last_name_kana', 'first_name_kana'| do
        before do
          params['profile'].except!('full_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('ヤマダ タロウ') }
        it { expect(profile.family_name_kana).to eq('ヤマダ') }
        it { expect(profile.given_name_kana).to eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ******* | -------- |
      context %q|with 'last_name_kana'| do
        before do
          params['profile'].except!('full_name_kana', 'first_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('ヤマダ') }
        it { expect(profile.family_name_kana).to eq('ヤマダ') }
        it { expect(profile.given_name_kana).to eq('') }
      end

      #     full(K) | last(K) | first(K) |
      # #2  ------- | ------- | ******** |
      context %q|with 'first_name_kana'| do
        before do
          params['profile'].except!('full_name_kana', 'last_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('タロウ') }
        it { expect(profile.family_name_kana).to eq('') }
        it { expect(profile.given_name_kana).to eq('タロウ') }
      end

      #     full(K) | last(K) | first(K) |
      # #3  ******* | ------- | -------- |
      context %q|with 'full_name_kana'| do
        before do
          params['profile'].except!('last_name_kana', 'first_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('ヤマダ タロウ') }
        it { expect(profile.family_name_kana).to eq('ヤマダ タロウ') }
        it { expect(profile.given_name_kana).to eq('') }
      end

      #     full(K) | last(K) | first(K) | full | last | first | user |
      # #5  ------- | ------- | -------- | ---- | ---- | ----- | ---- |
      context %q|with nothing| do
        before do
          params['profile'].except!('full_name_kana', 'last_name_kana', 'first_name_kana')
        end
        it { expect(profile.full_name_kana).to eq('') }
        it { expect(profile.family_name_kana).to eq('') }
        it { expect(profile.given_name_kana).to eq('') }
      end
    end

    describe '#zip_code' do
      it { expect(profile.zip_code).to eq('112-0002') }
      context %q|when 'postal_code' is missing| do
        before do
          params['profile'].except!('postal_code')
        end
        it { expect(profile.zip_code).to be_nil }
      end
    end

    describe 'location stuff' do
      it { expect(profile.prefecture).to eq(13) }
      it { expect(profile.prefecture_name).to eq('東京都') }
      it { expect(profile.city).to eq(13106) }
      it { expect(profile.location).to eq('文京区1-2-1') }

      context %q|'location_jis_id' is out of range| do
        before do
          params['profile']['location_jis_id'] = 50101
        end
        it { expect(profile.prefecture).to be_nil }
        it { expect(profile.prefecture_name).to eq('') }
        it { expect(profile.city).to be_nil }
        it { expect(profile.location).to eq('東京都文京区1-2-1') }
      end

      context %q|'location_jis_id' is missing| do
        before do
          params['profile'].except!('location_jis_id')
        end
        it { expect(profile.prefecture).to be_nil }
        it { expect(profile.prefecture_name).to eq('') }
        it { expect(profile.city).to be_nil }
        it { expect(profile.location).to eq('東京都文京区1-2-1') }
      end

      context %q|'location_jis_id' and 'location' are missing| do
        before do
          params['profile'].except!('location_jis_id', 'location')
        end
        it { expect(profile.prefecture).to be_nil }
        it { expect(profile.prefecture_name).to eq('') }
        it { expect(profile.city).to be_nil }
        it { expect(profile.location).to eq('') }
      end
    end

    describe 'birthday' do
      it { expect(profile.birthday).to eq(Date.parse('1990-1-1')) }

      context %q|when 'birthday' is missing| do
        before do
          params['profile'].except!('birthday')
        end
        it { expect(profile.birthday).to be_nil }
      end

      context %q|when 'birthday' is invalid| do
        before do
          params['profile']['birthday'] = '-1990-1-1'
        end
        it { expect(profile.birthday).to be_nil }
      end
    end

    describe 'gender' do
      it { expect(profile.gender).to eq(1) }

      context %q|when 'gender' is missing| do
        before do
          params['profile'].except!('gender')
        end
        it { expect(profile.gender).to be_nil }
      end

      context %q|when 'gender' is invalid| do
        before do
          params['profile']['gender'] = 99
        end
        it { expect(profile.gender).to be_nil }
      end
    end

    describe 'urls' do
      it { expect(profile.urls).to eq([ URI('http://example.com') ]) }

      context %q|when 'uri' is missing| do
        before do
          params['profile'].except!('uri')
        end
        it { expect(profile.urls).to eq([]) }
      end

      context %q|when 'uri' is empty| do
        before do
          params['profile']['uri'] = []
        end
        it { expect(profile.urls).to eq([]) }
      end

      context %q|when 'uri' is invalid| do
        before do
          params['profile']['uri'] = [ '-http://example.com' ]
        end
        it { expect(profile.urls).to eq([]) }
      end
      context %q|when scheme of 'uri' is invalid| do
        before do
          params['profile']['uri'] = [ 'ftp://example.com' ]
        end
        it { expect(profile.urls).to eq([]) }
      end
    end
    describe 'email' do
      it { expect(profile.emails).to eq(['taro-facebook@example.com', 'taro-twitter@example.com']) }

      context %q|when 'email' is missing| do
        before do
          params.except!('email')
        end
        it { expect(profile.emails).to eq([]) }
      end
      context %q|when 'email' is empty| do
        before do
          params['email'] = []
        end
        it { expect(profile.emails).to eq([]) }
      end
      context %q|when 'email[0]/email' is missing| do
        before do
          params['email'][0]['email'] = nil
        end
        it { expect(profile.emails).to eq(['taro-twitter@example.com']) }
      end
    end
  end
end
