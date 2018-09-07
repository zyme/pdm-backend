# frozen_string_literal: true

require 'hdm/oauth/state'
module Oauth
  class CallbackController < ApplicationController
    # this happens outof band from client right now,
    # will need to investigate how to deal with it
    # through the client
    skip_before_action :doorkeeper_authorize!
    def callback
      # validate code
      req = discover_request
      token = req[:provider].get_access_token(params[:code], redirect_uri: params[:redirect_uri])
      pp = link_provider_and_profile(token, req)
      render json: { id: pp.id }, status: :ok
    end

    private

    # state should be an encoded hash of the following values
    # profile_id
    # provider_id
    #

    # look up the request that is associated with the state that was passed
    # into the auth server.
    def discover_request
      # json = HDM::OAuth::State.decode(params[:state])
      ids = params[:state].split(':')
      { provider: Provider.find(ids[0]),
        profile: Profile.find(ids[1]) }
    end

    # perfrom the code validation step
    # send back to the authorization server and get an access token and refresh token
    def link_provider_and_profile(token, req)
      pp = ProfileProvider.new
      pp.profile = req[:profile]
      pp.provider = req[:provider]
      pp.access_token = token.token
      pp.expires_at = Time.now.to_i + token.expires_in
      pp.refresh_token = token.refresh_token
      pp.subject_id = pp.provider.subject_id_from_token(token)
      pp.scopes = token.params['scope']
      pp.save!
      SyncProfileProviderJob.perform_later(pp)
      pp
    end
  end
end
