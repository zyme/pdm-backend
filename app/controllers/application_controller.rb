class ApplicationController < ActionController::API
  respond_to :json
  class NotFoundException < Exception

  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render :json => {}, :status => 404
  end

  before_action :doorkeeper_authorize!

  private
    # Doorkeeper methods
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

end
