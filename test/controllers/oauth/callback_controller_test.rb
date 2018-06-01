require 'test_helper'

class Api::V1::ProfilesControllerTest < ActionDispatch::IntegrationTest

  test "should be able to handle callback from auth servers" do
    data = {"access_token": "m7rt6i7s9nuxkjvi8vsx",
            "token_type": "bearer",
            "expires_in": 3600,
            "scope": "patient/Observation.read patient/Patient.read",
            "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA",
            "patient": ""
            }
    FakeWeb.register_uri(:any, %r{http://fitbit.com/api/oauth/token}, body: data.to_json, content_type: 'application/json')
    profile = profiles(:harrys_profile)
    provider = providers(:fitbit)
    assert_equal 0, ProfileProvider.where(profile_id: profile.id, provider_id: provider.id).count
    state = HDM::OAuth::State.encode(provider.id,profile.id)
    code = "this is a test code"

    get "/oauth/callback", params: { code: code, state: state }

    assert_redirected_to "http://www.example.com/profile/#{profile.id}/providers/#{provider.id}"
    providers = ProfileProvider.where(profile_id: profile.id, provider_id: provider.id)
    assert_equal 1, providers.count
    provider = providers.first
    assert_equal data[:access_token], provider.access_token
    assert_equal data[:refresh_token], provider.refresh_token


  end

end
