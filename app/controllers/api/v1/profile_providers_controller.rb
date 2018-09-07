# frozen_string_literal: true

module Api
  module V1
    class ProfileProvidersController < ApiController
      def index
        render json: find_profile.profile_providers, status: :ok
      end

      def create
        profile = find_profile
        provider = find_provider
        if profile.has_provider? provider
          render json: { message: 'Provider already linked' }, status: :internal_server_error
          return
        end
        state = { provider_id: provider.id, profile_id: profile.id }.to_json
        state_enc = Base64.encode64(state)
        state_enc = "#{provider.id}:#{profile.id}"
        redirect_uri = provider.generate_auth_url(redirect_uri: params[:redirect_uri], state: state_enc)
        render json: { redirect_uri: redirect_uri }, status: :ok
        # kick off the linking -- actual creation of the user_provider object happens
        # through an ouath2 flow to have the user log into the provider system and
        # grant access, the redirection of this will result in the object being created
        # once the
      end

      def destroy
        provider_link = find_profile.profile_providers.find(params[:id])
        provider_link.destroy
        render json: { message: 'provider removed' }, status: :no_content
      end

      private

      def find_provider
        Provider.find(params[:provider_id])
      end

      def find_profile
        current_resource_owner.profiles.find(params[:profile_id])
      end
    end
  end
end
