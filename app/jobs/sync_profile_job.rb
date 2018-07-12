# frozen_string_literal: true

class SyncProfileJob < ApplicationJob
  queue_as :default

  def perform(profile)
    profile.profile_providers.each do |pp|
      SyncProfileProviderJob.perform_now(pp)
    end
  end
end
