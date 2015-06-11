require 'active_support/core_ext/hash/deep_merge'
require 'social_plus/web_api/user'
require 'support/macros/social_plus_macros'

describe SocialPlus::WebApi::User do
  include SocialPlusMacros

  describe '.authenticate' do
    let(:api_client) { double(:api_client) }
    let(:token) { '1234567812345678123456781234567812345678' }
    let(:user) { double(:user) }

    before :each do
      allow(api_client).to receive(:execute).with('authenticated_user', token: token, add_profile: true).and_return(authenticated_user_api_result)
      allow(api_client).to receive(:execute).with('providers_of_user', identifier: authenticated_user_api_result['user']['identifier']).and_return(providers_of_user_api_result)
      allow(SocialPlus::WebApi::User).to receive(:new).with(social_plus_user_params).and_return(user)
    end

    it { expect(SocialPlus::WebApi::User.authenticate(api_client, token)).to eq(user) }
  end

  let(:social_plus_user) { SocialPlus::WebApi::User.send(:new, social_plus_user_params) }

  let(:last_logged_in_provider) { social_plus_user.last_logged_in_provider }

  shared_examples_for 'an User instance' do
    describe '#identifier' do
      it { expect(social_plus_user.identifier).to eq('12345abcde12345abcde12345abcde12345abcde') }
    end

    describe '#profile' do
      it { expect(social_plus_user.profile).to be_an_instance_of(SocialPlus::WebApi::Profile) }
    end

    describe '#followers' do
      it { expect(social_plus_user.followers).to eq(200) }
    end
  end

  context 'logged in directly' do
    it_behaves_like 'an User instance'

    describe '#last_logged_in_provider' do
      it { expect(last_logged_in_provider).to eq('feedforce') }

      describe '#facebook?' do
        it { expect(last_logged_in_provider.facebook?).to eq(false) }
      end

      describe '#twitter?' do
        it { expect(last_logged_in_provider.twitter?).to eq(false) }
      end
    end
  end

  context 'logged in via facebook' do
    before do
      social_plus_user_params.deep_merge!('user' => { 'last_logged_in_provider' => 'facebook' })
    end

    it_behaves_like 'an User instance'

    describe '#last_logged_in_provider' do
      it { expect(last_logged_in_provider).to eq('facebook') }

      describe '#facebook?' do
        it { expect(last_logged_in_provider.facebook?).to eq(true) }
      end

      describe '#twitter?' do
        it { expect(last_logged_in_provider.twitter?).to eq(false) }
      end
    end
  end

  context 'logged in via twitter' do
    before do
      social_plus_user_params.deep_merge!('user' => { 'last_logged_in_provider' => 'twitter' })
    end

    it_behaves_like 'an User instance'

    describe '#last_logged_in_provider' do
      it { expect(last_logged_in_provider).to eq('twitter') }

      describe '#facebook?' do
        it { expect(last_logged_in_provider.facebook?).to eq(false) }
      end

      describe '#twitter?' do
        it { expect(last_logged_in_provider.twitter?).to eq(true) }
      end
    end
  end

  context %q|when 'user' is missing| do
    before do
      social_plus_user_params.except!('user')
    end

    it 'should raise error' do
      expect { social_plus_user }.to raise_error(ArgumentError, %q|missing 'user'|)
    end
  end

  context %q|when 'user/identifier' is missing| do
    before do
      social_plus_user_params['user'].except!('identifier')
    end

    it 'should raise error' do
      expect { social_plus_user }.to raise_error(ArgumentError, %q|missing 'user/identifier'|)
    end
  end

  describe '#followers' do
    context %q|when 'follow' is missing| do
      before do
        social_plus_user_params.except!('follow')
      end

      it { expect(social_plus_user.followers).to eq(0) }
    end

    context %q|when 'follow/followed_by' is missing| do
      before do
        social_plus_user_params['follow'].except!('followed_by')
      end

      it { expect(social_plus_user.followers).to eq(0) }
    end
  end
end
