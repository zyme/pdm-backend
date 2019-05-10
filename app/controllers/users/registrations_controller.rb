# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  respond_to :html, only: []
  respond_to :xml, only: []

  skip_before_action :doorkeeper_authorize!

  before_action :not_allowed, only: %i[new edit cancel]

  def not_allowed
    raise MethodNotAllowed
  end

  def create
    super do |user|
      # Simply add the IP address to the user object
      user.dua_remote_ip = request.ip
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(%i[
                                   email
                                   password
                                   password_confirmation
                                   first_name
                                   last_name
                                   dua_accepted_at
                                   dua_agreed_to
                                   dua_legal_name
                                 ])
  end

  def account_update_params
    params.require(:user).permit(%i[
                                   email
                                   first_name
                                   last_name
                                 ])
  end
end
