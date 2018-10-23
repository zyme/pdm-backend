# frozen_string_literal: true

class UpdateChannel < ApplicationCable::Channel
  def subscribed
    current_profile = current_user.profiles.find(params[:profile_id])
    stream_for current_profile
    UpdateChannel.broadcast_to(current_profile, current_profile.reload.bundle_everything)
  end
end
