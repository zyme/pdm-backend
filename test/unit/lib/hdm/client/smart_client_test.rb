# frozen_string_literal: true

require 'test_helper'

class HDM::Client::SmartClientTest < ActiveSupport::TestCase
  def load_bundle(name)
    File.read(File.join(__dir__, "../../../../fixtures/files/bundles/#{name}.json"))
  end
  test 'should be able to generate auth redirection url for clients' do
    # mock the meta data endpoint
    fake_body = File.read(File.join(__dir__, '../../../../fixtures/files/ouath_capability_statement.json'))
    FakeWeb.register_uri(:any, %r{http://partners.com/}, body: fake_body, content_type: 'application/json')
    p = profile_providers(:harry_partners)
    bc = HDM::Client::SmartClient.new(p.provider)
    auth_url = URI(bc.generate_auth_url)
    assert auth_url
    assert_equal 'http', auth_url.scheme
    assert_equal 'partners.com', auth_url.host
    assert_equal '/oauth/auth', auth_url.path
    params = Rack::Utils.parse_query auth_url.query
    assert_equal 'http://partners.com/smart', params['aud']
    assert_equal 'partners id', params['client_id']
    assert_equal 'http://127.0.0.1:3000/oauth/callback', params['redirect_uri']
    assert_equal 'code', params['response_type']
    assert_equal nil, params['scope']
  end

  test 'should be able to get refresh token' do
    FakeWeb.register_uri(:post, %r{http://partners.com/oauth/token}, body: { access_token: 'new token', expires_in: 3600 }.to_json, content_type: 'application/json')
    p = profile_providers(:harry_partners)
    bc = HDM::Client::SmartClient.new(p.provider)
    bc.refresh(p)
  end

  test 'should be only refresh token when current one has expired' do
    FakeWeb.register_uri(:post, %r{http://partners.com/oauth/token}, body: { access_token: 'new token', expires_in: 3600 }.to_json, content_type: 'application/json')
    p = profile_providers(:harry_partners)
    bc = HDM::Client::SmartClient.new(p.provider)

    assert_equal 'this_is_harrys_access_token', p.access_token
    assert p.refresh_token
    exp = Time.now.to_i + 5000
    p.expires_at = exp
    p.save
    bc.refresh(p)
    p.reload
    # test that nothing has changed, expires_at is the same so is the token
    assert_equal 'this_is_harrys_access_token', p.access_token
    assert_equal exp, p.expires_at

    exp = Time.now.to_i - 5000
    p.expires_at = exp
    p.save
    bc.refresh(p)
    p.reload
    assert_equal 'new token', p.access_token
    assert_equal Time.now.to_i + 3600, p.expires_at
  end

  test 'should be able to sync data' do
    fake_body = File.read(File.join(__dir__, '../../../../fixtures/files/ouath_capability_statement.json'))
    FakeWeb.register_uri(:post, %r{http://partners.com/oauth/token}, body: { access_token: 'new token', expires_in: 3600 }.to_json, content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/metadata}, body: fake_body, content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Observation}, body: load_bundle('search-set'), content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Patient}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Encounter}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/MedicationAdminstration}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/MedicationOrder}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/MedicationStatement}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Device}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Immunization}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Condition}, body: '{}', content_type: 'application/json')
    FakeWeb.register_uri(:get, %r{http://partners.com/smart/Encounter}, body: '{}', content_type: 'application/json')

    p = profile_providers(:harry_partners)
    bc = HDM::Client::SmartClient.new(p.provider)
    bc.sync_profile(p)
  end
end
