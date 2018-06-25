# frozen_string_literal: true

module Api
  module V1
    class CuratedModelsController < ApiController
      before_action :set_model_class
      before_action :find_profile

      def index
        # byebug
        results = authorized_resources.where(filtered_params)

        unless params[:raw_models]
          # get just the FHIR resources
          results = results.map(&:resource)
        end

        render json: results, status: :ok
      end

      def show
        result = authorized_resources.find(params[:id])

        unless result.nil? || params[:raw_models]
          # get just the FHIR resource
          result = result.resource
        end

        render json: result, status: :ok
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
