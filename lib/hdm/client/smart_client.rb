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
                       FHIR::Observation]
      def intialize(provider)
        super(provider)
      end


      def sync_profile(profile_provider)
        if profile_provider.instance_of? Profile
          profile_provider = provider.profile_providers.find_by_profile_id(profile_provider.profile_id)
        end
        refresh(profile_provider)
        fhir_client.set_bearer_token(profile_provider.access_token)
        supported_resource_types.each do |type|
          reply = fhir_client.search(type, search: {parameters: {patient: profile_provider.subject_id}})
          bundle = reply.resource
          if bundle
             trans = Transaction.new(profile_id: profile_provider.profile.id,
                            provider_id: provider.id,
                            transaction_type: "fhir_bundle",
                            data: bundle.as_json )
             unless trans.save
               puts trans.errors
             end
          end
        end
        profile_provider.last_sync = Time.now
        profile_provider.save
      end

    private
      def fhir_client
        @fhir_client ||=  FHIR::Client.new(provider.base_endpoint)
        @fhir_client.default_json
        @fhir_client
      end
      def supported_resource_types
          types = []
          client_capability_statement.rest[0].resource.each do |r|
             if r.type != 'Patient' && r.searchParams.find{|sp| sp.name == "patient"}
               types << "FHIR::#{r.type}"
             end
          end
          types.empty? ? DEFAULT_TYPES : types
      end

      def client_capability_statement
        fhir_client.capability_statement
      end

      def get_endpoint_params()
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
