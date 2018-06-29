# frozen_string_literal: true

module Api
  module V1
    class PatientsController < ApiController
      def index
        patients = current_resource_owner.profiles.map { |p| { resource: map_profile_to_patient(p).to_hash } }

        bundle = FHIR::Bundle.new(type: 'searchset', entry: patients)

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: bundle.to_json, status: :ok
      end

      def show
        patient = map_profile_to_patient(find_profile)

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: patient.to_json, status: :ok
      end

      def everything
        profile = find_profile
        patient = map_profile_to_patient(profile)

        everything_else = profile.all_resources

        bundle = wrap_in_bundle(everything_else)

        bundle.entry.unshift(FHIR::Bundle::Entry.new(resource: patient.to_hash))

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: bundle.to_json, status: :ok
      end

      private

      def map_profile_to_patient(profile)
        FHIR::Patient.new(id: profile.id,
                          name: [{ given: [profile.first_name],
                                   family: profile.last_name,
                                   use: 'official' }],
                          gender: profile.gender)
      end

      def find_profile
        current_resource_owner.profiles.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def profile_params
        params.require(:profile).permit(:name, :first_name, :last_name, :dob, :gender)
      end
    end
  end
end
