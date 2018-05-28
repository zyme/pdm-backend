class Client < ApplicationRecord

  def generate_auth_url_for_provider(provider)


    client = FHIR::Client.new(provider.end_point)
    oauth_info = client.get_oauth2_metadata_from_conformance
    client.set_oauth2_auth(client_id, client_secret, oauth_info[:authorize_url], oauth_info[:token_url])
    client.client.auth_code.authorize_url(:redirect_uri => 'http://localhost:8080/oauth2/callback',
                                   scopes: [:openid, :profile, :offline_access, "patient/*.read"])
  end


end
