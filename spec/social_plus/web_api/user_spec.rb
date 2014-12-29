# -*- coding: utf-8 -*-

require 'active_support/core_ext/hash/deep_merge'

require 'social_plus/web_api/user'

describe SocialPlus::WebApi::User do
  let(:api_client) { double(:api_client) }
  let(:token) { '1234567812345678123456781234567812345678' }

  include SocialPlusMacros

  describe '.authenticate' do
    let(:user) { double(:user) }
    subject { SocialPlus::WebApi::User.authenticate(api_client, token) }

    before :each do
      api_client.stub(:execute).with('authenticated_user', token: token, add_profile: true).and_return(authenticated_user_api_result)
      api_client.stub(:execute).with('providers_of_user', identifier: authenticated_user_api_result['user']['identifier']).and_return(providers_of_user_api_result)
      SocialPlus::WebApi::User.stub(:new).with(social_plus_user_params).and_return(user)
    end

    it { should eq(user) }
  end

  describe '#initialize' do
    let(:social_plus_user) { SocialPlus::WebApi::User.send(:new, social_plus_user_params) }
    subject { social_plus_user }

    it { expect(social_plus_user.identifier).to eq('12345abcde12345abcde12345abcde12345abcde') }
    it { expect(social_plus_user.last_logged_in_provider).to eq('feedforce') }
    it { expect(social_plus_user.last_logged_in_provider.facebook?).to eq(false) }
    it { expect(social_plus_user.last_logged_in_provider.twitter?).to eq(false) }

    context 'logged in via facebook' do
      let(:social_plus_user) { SocialPlus::WebApi::User.send(:new, social_plus_user_params.deep_merge('user' => {'last_logged_in_provider' => 'facebook'})) }
      it { expect(social_plus_user.last_logged_in_provider).to eq('facebook') }
      it { expect(social_plus_user.last_logged_in_provider.facebook?).to eq(true) }
      it { expect(social_plus_user.last_logged_in_provider.twitter?).to eq(false) }
    end
    context 'logged in via twitter' do
      let(:social_plus_user) { SocialPlus::WebApi::User.send(:new, social_plus_user_params.deep_merge('user' => {'last_logged_in_provider' => 'twitter'})) }
      it { expect(social_plus_user.last_logged_in_provider).to eq('twitter') }
      it { expect(social_plus_user.last_logged_in_provider.facebook?).to eq(false) }
      it { expect(social_plus_user.last_logged_in_provider.twitter?).to eq(true) }
    end

    it { expect(social_plus_user.profile).to be_an_instance_of(SocialPlus::WebApi::Profile) }
    it { expect(social_plus_user.followers).to eq(200) }

    context %q|when 'user' is missing| do
      before do
        social_plus_user_params.except!('user')
      end
      it 'should raise error' do
        expect { subject }.to raise_error(ArgumentError, %q|missing 'user'|)
      end
    end

    context %q|when 'identifier' is missing| do
      before do
        social_plus_user_params['user'].except!('identifier')
      end
      it 'should raise error' do
        expect { subject }.to raise_error(ArgumentError, %q|missing 'user/identifier'|)
      end
    end

    context %q|wen 'follow' is missing| do
      before do
        social_plus_user_params.except!('follow')
      end
      it { expect(social_plus_user.followers).to eq(0) }
    end
    context %q|wen 'follow/followed_by' is missing| do
      before do
        social_plus_user_params['follow'].except!('followed_by')
      end
      it { expect(social_plus_user.followers).to eq(0) }
    end
  end
end
