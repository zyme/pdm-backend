require 'test_helper'

class Api::V1::ProfilesControllerTest < ActionDispatch::IntegrationTest

  test "user should be able to get list of their profiles" do
    user = users(:harry)
    token = generate_token(user.id)
    get "/api/v1/profiles", params: { :access_token => token.token}
    assert_response :success
    puts response.body
  end

  test "user should be able to get a specific  profiles" do
    user = users(:harry)
    token = generate_token(user.id)
    get "/api/v1/profiles/#{user.profiles.first.id}", params: {:access_token => token.token}
    assert_response :success
  end

  test "user should not be able to get another users  profile" do
    harry = users(:harry)
    token = generate_token(harry.id)
    sema = users(:sema)
    get "/api/v1/profiles/#{sema.profiles.first.id}", params: {  :access_token => token.token}
    assert_response :not_found

  end
  # test "User should be able to create a new profile" do
  #
  # end
  #
  #
  # test "user should be able to update a profile" do
  #
  # end
  #
  #
  # test "user should be able to delete a profile" do
  #
  #
  # end
  #
  #
  # test "user should be able to get individual profile" do
  #
  #
  # end
  #
  # test "user should not be able to get a profile that is not their own" do
  #
  # end


end
