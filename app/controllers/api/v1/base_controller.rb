# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApiController
      def create
        # identify provider based on the token
        provider = ProviderApplication.find_by(application_id: doorkeeper_token.application_id).provider

        bundle_json = request.body.read

        # identify profile based on identifiers in the Patient entry
        profile_id = find_profile_id(bundle_json)
        profile = Profile.find(profile_id)

        dr = DataReceipt.new(profile: profile,
                             provider: provider,
                             data: bundle_json,
                             data_type: 'fhir_bundle_edr')
        dr.save!

        # run the sync job async
        # SyncProfileJob.perform_later(profile)

        render status: :ok
      end

      private

      def find_profile_id(bundle_json)
        bundle = FHIR::Json.from_json(bundle_json)
        patient = bundle.entry.find { |e| e.resource.resourceType == 'Patient' }.resource
        ids = patient.identifier
        ident = ids.find { |id| id.system == 'urn:health_data_manager:profile_id' }
        ident.value
      end
    end
  end
end
