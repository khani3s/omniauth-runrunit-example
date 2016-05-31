require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Runrunit < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "runrunit"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        site: 'https://secure.runrun.it',
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid do
        raw_info['id']
      end

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          enterprise_id: raw_info['enterprise_id']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        # Make a request to "/api/users/me" and get information about the current user
        @raw_info ||= access_token.get('api/users/me').parsed
      end
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :runrunit, ENV["RUNRUNIT_CLIENT_ID"], ENV["RUNRUNIT_SECRET"]
end

OmniAuth.config.logger = Rails.logger
HttpLog.options[:logger] = Rails.logger
