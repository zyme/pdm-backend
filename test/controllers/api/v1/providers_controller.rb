require 'test_helper'

class Api::V1::ProvidersControllerTest < ActionDispatch::IntegrationTest

  test "SHould be able to get list of providers" do
    user = users(:harry)
    token = generate_token(user.id)
    get "/api/v1/providers", params: { :access_token => token.token}
    assert_response :success
  end

  test "Should be able to get a single provider" do
    user = users(:harry)
    token = generate_token(user.id)
    get "/api/v1/providers/#{Provider.first.id}", params: { :access_token => token.token}
    assert_response :success
  end

end
