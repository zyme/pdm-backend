# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApiController
      def index
        render json: current_resource_owner.profiles.as_json(methods: [:alerts]), status: :ok
      end

      def show
        render json: find_profile.as_json(methods: [:alerts]), status: :ok
      end

      def create
        profile = current_resource_owner.profiles.build(profile_params)
        profile.save!
        render json: profile.as_json(methods: [:alerts]), status: :created
      end

      def update
        profile = find_profile
        render json: profile.as_json(methods: [:alerts]), status: :ok if profile.update(profile_params)
      end

      def destroy
        profile = find_profile
        render json: profile, status: :ok if profile.delete
      end

      private

      def find_profile
        current_resource_owner.profiles.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def profile_params
        params.require(:profile).permit(:name, :first_name, :last_name, :dob,
                                        :gender, :middle_name, :street, :city,
                                        :state, :zip, :relationship, :telephone, :telephone_use)
      end
    end
  end
end
