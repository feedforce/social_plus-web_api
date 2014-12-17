# -*- coding: utf-8 -*-

require 'spec_helper'
require 'social_plus/web_api/user'

describe SocialPlus::WebApi::User do
  let(:api_client) { double(:api_client) }
  let(:token) { '1234567812345678123456781234567812345678' }

  include SocialPlusMacros

  describe '.authenticate' do
    let(:user) { double(:user) }
    subject { described_class.authenticate(api_client, token) }

    before :each do
      api_client.stub(:execute).with('authenticated_user', token: token, add_profile: true).and_return(authenticated_user_api_result)
      api_client.stub(:execute).with('providers_of_user', identifier: authenticated_user_api_result['user']['identifier']).and_return(providers_of_user_api_result)
      SocialPlus::User.stub(:new).with(social_plus_user_params).and_return(user)
    end

    it { should eq(user) }
  end

  describe '#initialize' do
    subject { described_class.send(:new, social_plus_user_params) }
    its(:identifier) { should eq('12345abcde12345abcde12345abcde12345abcde') }
    its(:last_logged_in_provider) { should eq('feedforce') }
    its('last_logged_in_provider.facebook?') { should == false }
    its('last_logged_in_provider.twitter?') { should == false }

    context 'logged in via facebook' do
      subject { described_class.send(:new, social_plus_user_params.deep_merge('user' => {'last_logged_in_provider' => 'facebook'})) }
      its(:last_logged_in_provider) { should eq('facebook') }
      its('last_logged_in_provider.facebook?') { should == true }
      its('last_logged_in_provider.twitter?') { should == false }
    end
    context 'logged in via twitter' do
      subject { described_class.send(:new, social_plus_user_params.deep_merge('user' => {'last_logged_in_provider' => 'twitter'})) }
      its(:last_logged_in_provider) { should eq('twitter') }
      its('last_logged_in_provider.facebook?') { should == false }
      its('last_logged_in_provider.twitter?') { should == true }
    end

    its(:profile) { should be_an_instance_of(SocialPlus::Profile) }
    its(:followers) { should eq(200) }

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
      its(:followers) { should eq(0) }
    end
    context %q|wen 'follow/followed_by' is missing| do
      before do
        social_plus_user_params['follow'].except!('followed_by')
      end
      its(:followers) { should eq(0) }
    end
  end
end
