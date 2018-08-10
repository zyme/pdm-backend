# frozen_string_literal: true

module HDM
  module Client
    class AllscriptsSmartClient < SmartClient
      def get_access_token(code, params = {})
        options = get_endpoint_params
        options[:site] = provider.base_endpoint
        options[:raise_errors] = true
        params[:redirect_uri] = 'http://localhost:3001/oauth'
        client = OAuth2::Client.new(provider.client_id, provider.client_secret, options)
        client.auth_code.get_token(code, params)
      end

      def fhir_search_client(profile_provider)
        FHIR::Client.new("#{provider.base_endpoint}/Patient/#{profile_provider.subject_id}")
      end

      def fhir_search_params(profile_provider)
        params = {}
        # see https://www.hl7.org/fhir/search.html#lastUpdate
        params[:_lastUpdated] = 'gt' + profile_provider.last_sync.iso8601 if profile_provider.last_sync

        { parameters: params }
      end

      def supported_resource_types
        HDM::Client::SmartClient::DEFAULT_DSTU2_TYPES
      end
    end
  end
end
