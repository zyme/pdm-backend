class SyncUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    UserProviders.where{last_sync < Time.now }.each do |up|
      SyncUserJob.perform_later(up)
    end
  end
end
