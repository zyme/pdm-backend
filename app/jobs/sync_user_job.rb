class SyncUserJob < ApplicationJob
  queue_as :default

  def perform(*args)
    up =   profile.profile_providers 
    # which client is it?
    client = up.provider.client
    # resolve the client that does the work
    pull_client = resolve_client(d)

    # configure the client with the meta data from the server conformance
    pull_client.config(up.provider.end_points)
    # set the refresh token on the client
    pull_client.set_refresh_token(up.refresh_token)
    # Call method to refresh the token and gt an access token
    # this call should set the access token that the client will use for this
    # sync operation
    access_token = pull_client.refresh
    up.access_token=access_token
    pull_client.sync(up)
    up.last_sync=now
    up.save
      # Do something later
  end

private

  def resolve_client(client)

  end

end
