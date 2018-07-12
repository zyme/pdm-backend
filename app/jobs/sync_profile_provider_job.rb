# frozen_string_literal: true

class SyncProfileProviderJob < ApplicationJob
  queue_as :default

  def perform(profile_provider)
    client = HDM::Client.get_client(profile_provider.provider)
    client.sync_profile(profile_provider)
    DataReceipt.where(profile: profile_provider.profile).each(&:process!)
    HDM::Merge:: Merger.new.update_profile(profile_provider.profile)
  end
end
