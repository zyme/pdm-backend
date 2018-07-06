# frozen_string_literal: true

module HDM
  module Client
    class SmartClient < BaseClient
      attr_accessor :fhir_client
      DEFAULT_TYPES = [FHIR::Patient,
                       FHIR::Immunization,
                       FHIR::Condition,
                       FHIR::Device,
                       FHIR::MedicationStatement,
                       FHIR::Encounter,
                       FHIR::Observation].freeze
      def intialize(provider)
        super(provider)
      end

      # Get the subject id from the OAuth2 token passed in.  This will look in a variety of
      # common locations for the id.  Specific implementaions of this class may need to overwrite
      # with implementation specific logic
      def subject_id_from_token(token)
        token.params['patient'] || token.params['patient_id'] || token.params['user_id'] || subject_id_from_id_token(token.params['id_token'])
      end

      # probably only applicable to the smart on fhir sandbox.  Other implementations
      # may need to reach back to the server to ask for the profile to obtain the patient id.
      def subject_id_from_id_token(token)
        return nil unless token
        jwt = JWT.decode(token, nil, false)
        payload = jwt[0]
        payload['profile'].gsub('Patient/', '')
      end

      def sync_profile(profile_provider)
        profile_provider = provider.profile_providers.find_by(profile_id: profile_provider.profile_id) if profile_provider.instance_of? Profile
        refresh(profile_provider)
        fhir_client.set_bearer_token(profile_provider.access_token)
        supported_resource_types.each do |type|
          reply = fhir_client.search(type, search: { parameters: { patient: profile_provider.subject_id } })
          bundle = reply.resource
          next unless bundle
          receipt = DataReceipt.new(profile_id: profile_provider.profile.id,
                                    provider_id: provider.id,
                                    data_type: 'fhir_bundle',
                                    data: bundle.as_json)
          puts receipt.errors unless receipt.save
        end
        profile_provider.last_sync = Time.now
        profile_provider.save
      end

      private

      def fhir_client
        @fhir_client ||= FHIR::Client.new(provider.base_endpoint)
        @fhir_client.default_json
        @fhir_client
      end

      def supported_resource_types
        types = []
        client_capability_statement.rest[0].resource.each do |r|
          if r.type != 'Patient' && r.searchParam.find { |sp| sp.name == 'patient' }
            types << "FHIR::#{r.type}".constantize
          end
        end
        types.empty? ? DEFAULT_TYPES : types
      end

      def client_capability_statement
        fhir_client.capability_statement
      end

      def get_endpoint_params
        super || discover_fhir_endpoint_params
      end

      def discover_fhir_endpoint_params
        fhir_client.default_json
        options = fhir_client.get_oauth2_metadata_from_conformance
        options
      end
    end
  end
end
