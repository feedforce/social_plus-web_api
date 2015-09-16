require 'social_plus/web_api/profile'
require 'active_support/core_ext/string/inquiry'
require 'active_support/core_ext/hash/slice'

# :nodoc:
module SocialPlus
  # :nodoc:
  module WebApi
    # A class which represents a user of Social Plus
    class User
      class << self
        # Fetch information of a user using a given one time token
        # @param [Client] api_client an API client
        # @param [String] token the token returned from Social Plus login
        # @return [User] User object
        def authenticate(api_client, token)
          result = api_client.execute('authenticated_user', token: token, add_profile: true)
          result['providers'] = api_client.execute('providers_of_user', identifier: result['user']['identifier'])['providers']
          new(result)
        end
        private :new
      end

      # rubocop: disable Metrics/AbcSize

      # @param [hash] params User information obtained from Social Plus Web API
      # @option params [Hash] "user" User
      # @option params [Hash] "profile" User's profile
      # @option params [Array] "email" User's email addresses
      # @option params [Hash] "follow" User's counts of following/followed people
      # @option params [Hash] "providers" Providers which the user has logged in
      def initialize(params)
        raise ArgumentError, %q|missing 'user'| unless params.key?('user')
        user = params['user']
        raise ArgumentError, %q|missing 'user/identifier'| unless user.key?('identifier')
        @identifier = user['identifier']
        last_logged_in_provider = user['last_logged_in_provider'] || ''
        @last_logged_in_provider = last_logged_in_provider.inquiry.freeze
        @profile = SocialPlus::WebApi::Profile.new(params.slice('profile', 'email')).freeze
        @followers = params.key?('follow') && params['follow'].key?('followed_by') ? params['follow']['followed_by'] : 0
        @providers = params['providers']
      end

      # rubocop: enable Metrics/AbcSize

      # @return [String] The user's Social Plus ID
      attr_reader :identifier
      # @return [ActiveSupport::StringInquirer] The provider which the user has logged in most recently
      attr_reader :last_logged_in_provider
      # @return [Profile] The user's profile
      attr_reader :profile
      # @return [Integer] The number of user's followers(reaches)
      attr_reader :followers
      # @return [Array] The Providers which the user has logged in
      attr_reader :providers
    end
  end
end
