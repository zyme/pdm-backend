# frozen_string_literal: true

class SyncProfileJob < ApplicationJob
  queue_as :default

  # fetch: if true, will fetch the latest for the profile from the provider. 
  # if false, will only run against what's already loaded
  def perform(profile, fetch = true)
    profile.profile_providers.each do |pp|
      SyncProfileProviderJob.perform_now(pp, fetch)
    end
  end
end
