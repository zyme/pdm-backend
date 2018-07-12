# frozen_string_literal: true

class SyncProfileJob < ApplicationJob
  queue_as :default

  def perform(profile)
    profile.profile_providers.each do |pp|
      SyncProfileProviderJob.perfom_now(pp)
    end
  end
end
