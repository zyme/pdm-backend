# frozen_string_literal: true

class UpdateChannel < ApplicationCable::Channel
  def subscribed
    current_profile = current_user.profiles.find(params[:profile_id])
    stream_for current_profile
  end
end
