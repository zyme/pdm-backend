# frozen_string_literal: true

module HDM
  module Client
    class AllscriptsSmartClient < SmartClient
      def subject_id_from_token(token)
        params = JWT.decode token.token, nil, false
        params[0]['local_patient_id'] || params[0]['sub']
      end

      def fhir_search_client(profile_provider)
        FHIR::Client.new("#{provider.base_endpoint}/Patient/#{profile_provider.subject_id}")
      end

      def fhir_search_params(profile_provider)
        params = {}
        params[:_lastUpdated] = 'gt' + profile_provider.last_sync.iso8601 if profile_provider.last_sync
        { parameters: params }
      end

      def supported_resource_types
        HDM::Client::SmartClient::DEFAULT_DSTU2_TYPES
      end
    end
  end
end
