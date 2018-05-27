class SyncUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ProfileProviders.where{last_sync < Time.now }.each do |pp|
      SyncUserJob.perform_later(pp)
    end
  end
end
