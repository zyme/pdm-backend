# frozen_string_literal: true

class SyncProfileJob < ApplicationJob
  queue_as :default

  # fetch: if true, will fetch the latest for the profile from the provider.
  # if false, will only run against what's already loaded
  def perform(profile, fetch = true)
    profile.profile_providers.each do |pp|
      SyncProfileProviderJob.perform_now(pp, fetch)
    end

    # fallback to catch any DRs that are associated with profiles/providers
    # for which there is no profile_provider link created
    # (for instance, an EDR where the person didn't already establish the link)
    DataReceipt.where(profile: profile, processed: nil).each(&:process!)
    HDM::Merge::Merger.new.update_profile(profile)
  end
end
