# frozen_string_literal: true

class ApplicationController < ActionController::API
  respond_to :json
  class NotFoundException < RuntimeError
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: {}, status: :not_found
  end

  before_action :doorkeeper_authorize!

  private

  # Doorkeeper methods
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
