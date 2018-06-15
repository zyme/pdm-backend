# frozen_string_literal: true

require 'test_helper'
require 'fakeweb'
class ProviderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'Provider should be able to generate auth redirection url for fhir clients' do
    # mock the meta data endpoint
    fake_body = File.read(File.join(__dir__, '../fixtures/files/ouath_capability_statement.json'))
    FakeWeb.register_uri(:any, %r{http://partners.com/}, body: fake_body, content_type: 'application/json')
    p = providers(:partners)
    url = p.generate_auth_url
    puts url
  end
end
