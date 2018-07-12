# frozen_string_literal: true

require 'test_helper'

class SyncProfileProviderJobTest < ActiveJob::TestCase
  # test "the truth" do
  #   assert true
  #
  def load_bundle(name)
    File.read(File.join(__dir__, "../fixtures/files/bundles/#{name}.json"))
  end

  test 'that profile provider is synced' do
    fake_body = File.read(File.join(__dir__, '../fixtures/files/ouath_capability_statement.json'))
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

    pp = profile_providers(:harry_partners)
    SyncProfileProviderJob.perform_now(pp)
    count = DataReceipt.count()
    assert DataReceipt.count() > count
  end
end
