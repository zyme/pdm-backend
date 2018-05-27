module Api

  module V1
    class ProfileProvidersController < ApiController

      def index
        byebug
        render json: current_resource_owner.profiles.find(params[:id]), status: 200
      end

      def create
         profile = find_profile
         provider = find_provider
         if provider_already_linked? provider
           return json: {message: "Provider already linked"}, status: 200
         end

        # kick off the linking -- actual creation of the user_provider object happens
        # through an ouath2 flow to have the user log into the provider system and
        # grant access, the redirection of this will result in the object being created
        # once the

      end

      def delete
        profile = current_resource_owner.profiles
        provider_link = current_resource_owner.user_providers.find(params[:id])
        if(provider_link)
          provider_link.destroy
        end
        return json: {message: "provider removed"}, 204
      endd

      private

      def permit()

      end
    end
  end

end
