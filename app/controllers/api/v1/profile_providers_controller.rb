module Api

  module V1
    class ProfileProvidersController < ApiController

      def index
        render json: current_resource_owner.profiles, status: 200
      end

      def create
         profile = find_profile
         provider = find_provider
         if profile.has_provider? provider
           render json: {message: "Provider already linked"}, status: 500
         end
        state = {provider_id: provider.id, profile_id: profile.id }.to_json
        state_enc = Base64.encode64(state)
        redirect_to provider.generate_auth_url(state: state_enc)
        # kick off the linking -- actual creation of the user_provider object happens
        # through an ouath2 flow to have the user log into the provider system and
        # grant access, the redirection of this will result in the object being created
        # once the
      end

      def destroy
        provider_link = find_profile.profile_providers.find(params[:id])
        provider_link.destroy
        render json: {message: "provider removed"}, status: 204
      end

      private

      def find_profile
        current_resource_owner.profiles.find(params[:profile_id])
      end
    end
  end
end
