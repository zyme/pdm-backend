# frozen_string_literal: true

require 'test_helper'
require 'uri'
class HDM::Client::BaseClientTest < ActiveSupport::TestCase
  test 'should be able to generate auth redirection url for clients' do
    # mock the meta data endpoint
    fake_body = File.read(File.join(__dir__, '../../../../fixtures/files/ouath_capability_statement.json'))
    FakeWeb.register_uri(:any, %r{http://partners.com/}, body: fake_body, content_type: 'application/json')
    p = profile_providers(:harry_partners)
    bc = HDM::Client::BaseClient.new(p.provider)
    auth_url = URI(bc.generate_auth_url)
    assert auth_url
    assert_equal 'http', auth_url.scheme
    assert_equal 'partners.com', auth_url.host
    assert_equal '/oauth/auth', auth_url.path
    params = Rack::Utils.parse_query auth_url.query
    assert_equal 'http://partners.com/smart', params['aud']
    assert_equal 'partners id', params['client_id']
    assert_equal 'http://localhost:3000/oauth/callback', params['redirect_uri']
    assert_equal 'code', params['response_type']
    assert_equal nil, params['scope']
  end
end
