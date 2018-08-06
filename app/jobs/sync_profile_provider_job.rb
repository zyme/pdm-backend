# frozen_string_literal: true

class SyncProfileProviderJob < ApplicationJob
  queue_as :default

  # fetch: if true, will fetch the latest for the profile from the provider. 
  # if false, will only run against what's already loaded
  def perform(profile_provider, fetch = true)
    if fetch
      client = HDM::Client.get_client(profile_provider.provider)
      client.sync_profile(profile_provider)
    end
    DataReceipt.where(profile: profile_provider.profile).each(&:process!)
    HDM::Merge::Merger.new.update_profile(profile_provider.profile)
  end
end
