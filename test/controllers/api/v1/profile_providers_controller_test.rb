# frozen_string_literal: true

require 'test_helper'

class Api::V1::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'user should be able to get list of their providers linked to profile' do
    user = users(:harry)
    token = generate_token(user.id)
    profile = user.profiles.first
    get "/api/v1/profiles/#{profile.id}/providers", params: { access_token: token.token }
    assert_response :success
  end

  test 'user should be able to unlink a provider from their profile' do
    user = users(:harry)
    token = generate_token(user.id)
    profile = user.profiles.first
    pp = profile.profile_providers.first
    delete "/api/v1/profiles/#{profile.id}/providers/#{pp.id}", params: { access_token: token.token }
    assert_response 204
    assert ProfileProvider.find_by(id: pp.id).nil?, 'Profile link should have been deleted'
  end
end
