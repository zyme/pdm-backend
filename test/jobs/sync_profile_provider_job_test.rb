# frozen_string_literal: true

require 'test_helper'

class SyncProfileProviderJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

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
    raw_resource_count = pp.profile.resources.count
    resource_count = pp.profile.all_resources.length
    count = DataReceipt.count()
    SyncProfileProviderJob.perform_now(pp)
    assert DataReceipt.count > count
    assert pp.profile.resources.count > raw_resource_count
    assert pp.profile.all_resources.length > resource_count
  end

  test 'that the profile is broadcast following the job' do
    pp = profile_providers(:really_smart)
    profile = pp.profile
    assert_broadcast_on(profile, profile.bundle_everything, channel: UpdateChannel) do
      SyncProfileProviderJob.perform_now(pp, false)
    end
  end

  test 'that nothing is broadcast following the job if called from SyncProfileJob' do
    pp = profile_providers(:really_smart)
    profile = pp.profile
    # assert_no_broadcasts seems to be broken, have to call assert_broadcasts with count = 0
    assert_broadcasts(profile, 0, channel: UpdateChannel) do
      SyncProfileProviderJob.perform_now(pp, false, true)
    end
  end
end
