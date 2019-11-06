# frozen_string_literal: true

module HDM
  module Client
    class SmartClient < BaseClient
      attr_accessor :fhir_client
      DEFAULT_STU3_TYPES = [FHIR::Patient,
                            FHIR::Immunization,
                            FHIR::Condition,
                            FHIR::Device,
                            FHIR::MedicationStatement,
                            FHIR::Encounter,
                            FHIR::Observation].freeze
      DEFAULT_DSTU2_TYPES = [FHIR::DSTU2::Patient,
                             FHIR::DSTU2::Immunization,
                             FHIR::DSTU2::Condition,
                             FHIR::DSTU2::Device,
                             FHIR::DSTU2::MedicationStatement,
                             FHIR::DSTU2::MedicationOrder,
                             FHIR::DSTU2::Procedure,
                             FHIR::DSTU2::CarePlan,
                             FHIR::DSTU2::Goal,
                             FHIR::DSTU2::Encounter,
                             FHIR::DSTU2::Observation].freeze
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
        payload['profile'].gsub('^Patient/', '')
      end

      def sync_profile(profile_provider)
        profile_provider = provider.profile_providers.find_by(profile_id: profile_provider.profile_id) if profile_provider.instance_of? Profile
        refresh(profile_provider)
        fclient = fhir_search_client(profile_provider)
        fclient.set_bearer_token(profile_provider.access_token)
        supported_resource_types.each do |type|
          reply = fclient.search(type, search: fhir_search_params(profile_provider))
          bundle = reply.resource

          # don't bother storing empty results
          next if bundle.nil? || bundle.entry.nil? || bundle.entry.none? || bundle.total == 0

          receipt = DataReceipt.new(profile_id: profile_provider.profile.id,
                                    provider_id: provider.id,
                                    data_type: 'fhir_bundle',
                                    data: bundle.as_json)
          receipt.save
        end
        profile_provider.last_sync = Time.now
        profile_provider.save
      end

      private

      def fhir_search_client(_profile_provider)
        fhir_client
      end

      def fhir_client
        @fhir_client ||= FHIR::Client.new(provider.base_endpoint)
        @fhir_client.default_json
        @fhir_client
      end

      def supported_resource_types
        version = fhir_client.detect_version
        version ||= :dstu2
        defaults = version == :dstu2 ? DEFAULT_DSTU2_TYPES : DEFAULT_STU3_TYPES
        prefix = version == :dstu2 ? 'FHIR::DSTU2' : 'FHIR'
        types = []
        client_capability_statement.rest[0].resource.each do |r|
          types << "#{prefix}::#{r.type}".constantize if r.type != 'Patient' && r.searchParam.find { |sp| sp.name == 'patient' }
        rescue NameError
          # If this fails, just ignore it
          nil
        end
        types.empty? ? defaults : types
      end

      def fhir_search_params(profile_provider)
        params = {}
        params[:patient] = profile_provider.subject_id

        # see https://www.hl7.org/fhir/search.html#lastUpdate
        params[:_lastUpdated] = 'gt' + profile_provider.last_sync.iso8601 if profile_provider.last_sync

        { parameters: params }
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

      def get_auth_params(params = {})
        params[:scope] = generate_scopes_from_conformance unless provider.scopes
        super(params)
      end

      def generate_scopes_from_conformance
        scopes = ''
        client_capability_statement.rest[0].resource.each do |r|
          scopes += "patient/#{r.type}.read "
        end
        scopes
      end
    end
  end
end
