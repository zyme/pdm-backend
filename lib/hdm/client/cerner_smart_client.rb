# frozen_string_literal: true

module HDM
  module Client
    class CernerSmartClient < SmartClient
      def get_access_token(code, params = {})
        options = get_endpoint_params
        options[:site] = provider.base_endpoint
        options[:raise_errors] = true
        params[:redirect_uri] = 'http://localhost:3001/oauth'
        client = OAuth2::Client.new(provider.client_id, provider.client_secret, options)
        client.auth_code.get_token(code, params)
      end
    end
  end
end
