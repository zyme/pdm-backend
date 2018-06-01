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
        token = req[:provider].get_access_token(params[:code])
        link_provider_and_profile(token, req)
        redirect_to "/profile/#{req[:profile].id}/providers/#{req[:provider].id}"
    end

    private
     # state should be an encoded hash of the following values
     # profile_id
     # provider_id
     #

    # look up the request that is associated with the state that was passed
    # into the auth server.
    def discover_request
      json = HDM::OAuth::State.decode(params[:state])
      json.merge({ provider: Provider.find(json["provider_id"]),
                   profile: Profile.find(json["profile_id"])})
    end


    # perfrom the code validation step
    # send back to the authorization server and get an access token and refresh token
    def link_provider_and_profile(token,req)
      pp = ProfileProvider.new()
      pp.profile = req[:profile]
      pp.provider = req[:provider]
      pp.access_token = token.token
      pp.refresh_token = token.refresh_token
      pp.subject_id = token.params["patient"] || token.params["patient_id"] || token.params["user_id"]
      pp.scopes = token.params["scope"]
      pp.save!
    end
  end
end
