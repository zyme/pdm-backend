# frozen_string_literal: true

require 'test_helper'

class Api::V1::CuratedModelsControllerTest < ActionDispatch::IntegrationTest
  test 'user should be able to get conditions for their profile' do
    user = users(:harry)
    token = generate_token(user.id)
    profile = user.profiles.first
    get "/api/v1/profiles/#{profile.id}/conditions", params: { access_token: token.token }
    assert_response :success
  end

  test 'user should be able to get conditions for their profile via FHIR API' do
    user = users(:harry)
    token = generate_token(user.id)
    profile = user.profiles.first
    get "/api/v1/Condition", params: { access_token: token.token }
    assert_response :success
  end
end
