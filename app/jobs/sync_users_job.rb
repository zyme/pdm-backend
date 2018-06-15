# frozen_string_literal: true

class SyncUsersJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    ProfileProvider.where('last_sync is null or last_sync < ?', Time.now).each do |pp|
      SyncUserJob.perform_later(pp)
    end
  end
end
