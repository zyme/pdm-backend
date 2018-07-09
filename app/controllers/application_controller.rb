# frozen_string_literal: true

class ApplicationController < ActionController::API
  respond_to :json
  class NotFoundException < RuntimeError
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: {}, status: :not_found
  end

  before_action :update_log
  before_action :doorkeeper_authorize!

  private

  # Doorkeeper methods
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  # Function to update the audit log as new events occur in a user's account.
  def update_log
    recorded_user = current_resource_owner&.id || 'N/A'
    description = controller_name + ' ' + action_name
    params.each do |variable|
      description = description + ' ' + variable.to_s
    end
    AuditLog.create(requester_info: recorded_user, event: 'event', event_time: Time.current.inspect, description: description)
  end
end
