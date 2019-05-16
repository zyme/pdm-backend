# frozen_string_literal: true

require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def test_connects_with_token
      user = users(:harry)
      token = Doorkeeper::AccessToken.create(resource_owner_id: user.id)

      connect "/cable?token=#{token.token}"

      assert_equal(user, connection.current_user)
    end

    def test_does_not_connect_without_token
      assert_reject_connection do
        connect
      end
    end
  end
end
