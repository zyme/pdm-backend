# frozen_string_literal: true

class UpdateChannelTest < ActionCable::Channel::TestCase
  def test_subscribe
    user = users(:harry)
    profile = profiles(:harrys_profile)

    stub_connection(current_user: user)

    subscribe profile_id: profile.id

    assert subscription.confirmed?
  end
end