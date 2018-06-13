module Api
  module V1
    class ProfilesController < ApiController

      def index
        render json: current_resource_owner.profiles, status: 200
      end

      def show
        render json: find_profile, status: 200
      end

      def create
        profile = current_resource_owner.profiles.build(profile_params)
        profile.save!
        render json: profile, status: 201
      end

      def update
        profile = find_profile
        if profile.update(profile_params)
          render json: profile, status: 200
        end
      end

      def destroy
        profile = find_profile
        if profile.delete
          render json: {message: "Deleted" }, status: 204
        end
      end

      private

      def find_profile
        current_resource_owner.profiles.find(params[:id])
      end
      # Never trust parameters from the scary internet, only allow the white list through.
     def profile_params
       params.require(:profile).permit(:name,:first_name,:last_name, :dob, :gender)
     end
   end
 end
end
