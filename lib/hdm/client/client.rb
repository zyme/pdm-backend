# frozen_string_literal: true

module HDM
  module Client
    def self.get_client(provider)
      if provider.provider_type == 'smart'
        HDM::Client::SmartClient.new(provider)
      elsif provider.provider_type == 'smart_epic'
        HDM::Client::EpicSmartClient.new(provider)
      else
        BaseClient.new(provider)
      end
    end

    class BaseClient
      attr_accessor :provider

      def initialize(provider)
        @provider = provider
      end

      def sync_profile(_profile_provider)
        raise 'Not Implemented'
      end

      def subject_id_from_token(token)
        token.params['patient'] || token.params['patient_id'] || token.params['user_id']
      end

      def refresh(profile_provider)
        # call the token endpoint with the refresh token to get a new access token_endpoint
        if profile_provider.refresh_token
          client_options = get_endpoint_params
          client = OAuth2::Client.new(provider.client_id, provider.client_secret, client_options)
          access_token = OAuth2::AccessToken.new(client, profile_provider.access_token, refresh_token: profile_provider.refresh_token)

          if access_token.refresh_token
            access_token = access_token.refresh!
            profile_provider.access_token = access_token.token
            profile_provider.refresh_token = access_token.refresh_token
            profile_provider.save
          end
        end
      end

      def generate_auth_url(params = {})
        generate_generic_auth_url(params)
      end

      def get_access_token(code, params = {})
        options = get_endpoint_params
        options[:site] = provider.base_endpoint
        options[:raise_errors] = true
        client = OAuth2::Client.new(provider.client_id, provider.client_secret, options)
        client.auth_code.get_token(code, params)
      end

      def generate_generic_auth_url(params = {})
        options = get_endpoint_params
        options[:site] = provider.base_endpoint
        options[:raise_errors] = true
        generate_oauth_auth_url(options, get_auth_params(params))
      end

      def generate_oauth_auth_url(client_options, auth_params)
        client = OAuth2::Client.new(provider.client_id, provider.client_secret, client_options)
        client.auth_code.authorize_url(auth_params)
      end

      def get_auth_params(params = {})
        { aud: provider.base_endpoint,
          redirect_uri:  default_redirect_endpoint,
          scope: provider.scopes }.merge params
      end

      def get_endpoint_params
        if provider.token_endpoint && provider.authorization_endpoint
          { authorize_url: provider.authorization_endpoint,
            token_url: provider.token_endpoint }
        end
      end

      def default_redirect_endpoint
        'http://127.0.0.1:3000/oauth/callback'
      end
    end
  end
end
