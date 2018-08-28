# frozen_string_literal: true

class SyncProfileProviderJob < ApplicationJob
  queue_as :default

  # fetch: if true, will fetch the latest for the profile from the provider.
  # if false, will only run against what's already loaded
  def perform(profile_provider, fetch = true, called_from_sync_profile_job = false)
    if fetch
      client = HDM::Client.get_client(profile_provider.provider)
      client.sync_profile(profile_provider)
    end

    profile = profile_provider.profile
    DataReceipt.where(profile: profile, processed: nil).each(&:process!)
    HDM::Merge::Merger.new.update_profile(profile)

    unless called_from_sync_profile_job
      # broadcast the entire patient bundle to any connected users
      # (reload ensures we get all the latest data -- seems to be some issues if that's removed)
      UpdateChannel.broadcast_to(profile, profile.reload.bundle_everything)
    end
  end
end
