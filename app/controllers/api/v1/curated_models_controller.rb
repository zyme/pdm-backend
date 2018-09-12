# frozen_string_literal: true

module Api
  module V1
    class CuratedModelsController < ApiController
      before_action :set_model_class
      before_action :find_profile

      def index
        results = authorized_resources.where(filtered_params)

        results = wrap_in_bundle(results) unless params[:raw_models]

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: results.to_json, status: :ok
      end

      def show
        result = authorized_resources.find(params[:id])

        unless result.nil? || params[:raw_models]
          # get just the FHIR resource
          result = result.resource
        end

        # pre-converting to json is a workaround for a bug w/ rails & fhir_models
        render json: result.to_json, status: :ok
      end

      private

      def authorized_resources
        @model_class.where(profile: @profile)
      end

      def find_profile
        @profile = if params[:profile_id]
                     current_resource_owner.profiles.find(params[:profile_id])
                   else
                     current_resource_owner.profiles
                   end
      end

      def wrap_in_bundle(results)
        # get just the FHIR resources, but then wrap it in an Entry.
        resources = results.map { |r| { resource: r.fhir_model.to_hash } }
        FHIR::Bundle.new(type: 'searchset', entry: resources)
      end

      def filtered_params
        params.permit(:profile_id, :id)
      end

      def set_model_class
        # which model class is this controller serving up?
        # ex. 'care_plans' -> 'CarePlan' -> <CarePlan> class
        @model_class = controller_name.classify.constantize
      end
    end
  end
end
