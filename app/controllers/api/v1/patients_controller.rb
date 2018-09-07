# frozen_string_literal: true

module Api
  module V1
    class PatientsController < ApiController
      def index
        patients = current_resource_owner.profiles.map { |p| { resource: p.to_patient.to_hash } }

        bundle = FHIR::Bundle.new(type: 'searchset', entry: patients)

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: bundle.to_json, status: :ok
      end

      def show
        patient = find_profile.to_patient

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: patient.to_json, status: :ok
      end

      def everything
        bundle = find_profile.bundle_everything
        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: bundle.to_json, status: :ok
      end

      private

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
