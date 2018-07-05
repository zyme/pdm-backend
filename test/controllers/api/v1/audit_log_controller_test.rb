# frozen_string_literal: true

require 'test_helper'

class Api::V1::AuditLogControllerTest < ActionDispatch::IntegrationTest
  test 'Should be able to record the users id in the audit log' do
    user = users(:harry)
    token = generate_token(user.id)
    get '/api/v1/providers', params: { access_token: token.token }
    log = AuditLog.first
    assert_equal(log.requester_info.to_i, user.id)
  end

  test 'Should be able to record the description of users actions' do
    user = users(:harry)
    token = generate_token(user.id)
    get '/api/v1/providers', params: { access_token: token.token }
    log = AuditLog.first
    assert_equal(log.description, "providers index [\"access_token\", \"#{token.token}\"] [\"format\", :json] [\"controller\", \"api/v1/providers\"] [\"action\", \"index\"]")
  end

  test 'user should be able to delete a profile and should be recorded in the audit log' do
    harry = users(:harry)
    token = generate_token(harry.id)
    profile = harry.profiles.first.id
    delete "/api/v1/profiles/#{harry.profiles.first.id}", params: { access_token: token.token }
    assert_response 200 # returning 200 because we are returning the deleted resource
    log = AuditLog.first
    log_description_action = log.description.split(" ")[1]
    assert_equal(log_description_action, "destroy" )
  end

  test 'audit log should show that user has created a new profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    profile = Profile.new(name: 'Test')
    count = harry.profiles.count
    post '/api/v1/profiles/', params: { profile: profile.as_json, access_token: token.token }
    log = AuditLog.first
    log_description_action = log.description.split(" ")[1]
    assert_equal(log_description_action, "create")
  end

  test 'audit log should show that user has updated a profile' do
    harry = users(:harry)
    token = generate_token(harry.id)
    profile = harry.profiles.first
    name = profile.name
    profile.name = 'new name'
    assert name != profile.name
    patch "/api/v1/profiles/#{harry.profiles.first.id}", params: { profile: profile.as_json, access_token: token.token }
    assert_response 200
    log = AuditLog.first
    log_description_action = log.description.split(" ")[1]
    assert_equal(log_description_action, "update")
  end
end
