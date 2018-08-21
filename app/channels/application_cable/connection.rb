# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # see https://github.com/doorkeeper-gem/doorkeeper/wiki/Doorkeeper-and-ActionCable
    def connect
      self.current_user = authenticate!
    end

    protected

    def authenticate!
      token = request.params[:token]
      access_token = Doorkeeper::AccessToken.by_token(token)
      user = User.find_by(id: access_token.try(:resource_owner_id))
      user || reject_unauthorized_connection
    end
  end
end
