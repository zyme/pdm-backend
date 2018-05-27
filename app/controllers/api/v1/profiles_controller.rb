class Api::V1::ProfilesController < ApplicationController

  def index
    render json: current_resource_owner.profiles, status: 200
  end

  def show
    render json: find_profile, status: 200
  end

  def update
    profile = find_profile
    if profile.update(params[:profile])
      render json: profile, status: 200
    end
  end

  def delete
    profile = find_profile
    if profile.delete
      render json: {message: "Deleted" }, status: 204
    end
  end

  private

  def find_profile
    current_resource_owner.profiles.find(params[:id])
  end
end
