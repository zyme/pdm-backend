# frozen_string_literal: true

require 'test_helper'

class Api::V1::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'user should be able to get list of their profiles' do
    user = users(:harry)
    token = generate_token(user.id)
    get '/api/v1/profiles', params: { access_token: token.token }
    assert_response :success
  end

  test 'user should be able to get a specific  profiles' do
    user = users(:harry)
    token = generate_token(user.id)
    get "/api/v1/profiles/#{user.profiles.first.id}", params: { access_token: token.token }
    assert_response :success
  end

  test 'user should not be able to get another users  profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    sema = users(:sema)
    get "/api/v1/profiles/#{sema.profiles.first.id}", params: { access_token: token.token }
    assert_response :not_found
  end

  test 'user should be able to delete a profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    profile = harry.profiles.first.id
    delete "/api/v1/profiles/#{harry.profiles.first.id}", params: { access_token: token.token }
    assert_response 200 # returning 200 because we are returning the deleted resource
    assert Profile.find_by(id: profile).nil?, 'Profile should have been deleted'
  end

  test 'user should not be able to delete another users profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    sema = users(:sema)
    profile = sema.profiles.first.id
    delete "/api/v1/profiles/#{profile}", params: { access_token: token.token }
    assert_response :not_found
    assert_not Profile.find_by(id: profile).nil?, 'Profile should not have been deleted'
  end

  test 'user should be able to create a new profile' do
    harry = users(:harry)
    hp = profiles(:harrys_profile)
    token = generate_token(harry.id)
    profile = hp.clone
    profile.name = 'Test'
    count = harry.profiles.count
    post '/api/v1/profiles/', params: { profile: profile.as_json, access_token: token.token }
    assert_response :created
    assert Profile.where(user_id: harry.id).count == count + 1, 'Should have created a new profile'
    new_profile = Profile.where(user_id: harry.id, name: 'Test').first
    assert new_profile
    assert_equal profile.first_name, new_profile.first_name
    assert_equal profile.last_name, new_profile.last_name
    assert_equal profile.middle_name, new_profile.middle_name
    assert_equal profile.gender, new_profile.gender
    assert_equal profile.dob, new_profile.dob
    assert_equal profile.street, new_profile.street
    assert_equal profile.city, new_profile.city
    assert_equal profile.state, new_profile.state
    assert_equal profile.zip, new_profile.zip
    assert_equal profile.relationship, new_profile.relationship
    assert_equal profile.telephone, new_profile.telephone
    assert_equal profile.telephone_use, new_profile.telephone_use
  end

  test 'user should be able to update a profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    profile = harry.profiles.first
    name = profile.name
    profile.name = 'new name'
    assert name != profile.name
    patch "/api/v1/profiles/#{harry.profiles.first.id}", params: { profile: profile.as_json, access_token: token.token }
    assert_response 200
    assert Profile.find_by(id: profile).name == 'new name', 'Profile should name should have changed have been deleted'
  end

  test 'user should not be able to update another users profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    sema = users(:sema)
    profile = sema.profiles.first
    profile.name = 'new name'
    assert name != profile.name
    patch "/api/v1/profiles/#{profile.id}", params: { profile: profile.as_json, access_token: token.token }
    assert_response :not_found
  end
end
