# frozen_string_literal: true

require 'test_helper'
require 'uri'
class HDM::Merge::MergerTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'should merge records from resource collection into currated records' do
    profile = profiles(:harrys_profile)
    provider = profile.providers.first
    load_resources(profile, provider)
    assert_equal 12, profile.resources.where(merged: false).count
    assert_equal profile.allergy_intolerances.length, 0
    assert_equal profile.care_plans.length, 0
    assert_equal profile.conditions.length, 0
    assert_equal profile.devices.length, 0
    assert_equal profile.encounters.length, 0
    assert_equal profile.immunizations.length, 0
    assert_equal profile.medication_administrations.length, 0
    assert_equal profile.medication_requests.length, 0
    assert_equal profile.medication_statements.length, 0
    assert_equal profile.observations.length, 0
    merger = HDM::Merge::Merger.new
    merger.update_profile(profile)
    profile.reload
    assert_equal 0, profile.resources.where(merged: false).count
    assert_equal 12, profile.resources.where(merged: true).count

    assert_equal profile.allergy_intolerances.length, 1
    assert_equal profile.care_plans.length, 1
    assert_equal profile.conditions.length, 1
    assert_equal profile.devices.length, 1
    assert_equal profile.encounters.length, 1
    assert_equal profile.immunizations.length, 1
    assert_equal profile.medication_administrations.length, 1
    assert_equal profile.medication_requests.length, 1
    assert_equal profile.medication_statements.length, 1
    assert_equal profile.observations.length, 1
  end

  test 'should not merge records that have already been merged' do
    profile = profiles(:harrys_profile)
    provider = profile.providers.first
    load_resources(profile, provider)
    assert_equal 12, profile.resources.where(merged: false).count
    merger = HDM::Merge::Merger.new
    # called multiple times to simulate updating the profile more than once
    merger.update_profile(profile)
    merger.update_profile(profile)
    merger.update_profile(profile)
    profile.reload
    assert_equal 0, profile.resources.where(merged: false).count
    assert_equal 12, profile.resources.where(merged: true).count

    assert_equal profile.allergy_intolerances.length, 1
    assert_equal profile.care_plans.length, 1
    assert_equal profile.conditions.length, 1
    assert_equal profile.devices.length, 1
    assert_equal profile.encounters.length, 1
    assert_equal profile.immunizations.length, 1
    assert_equal profile.medication_administrations.length, 1
    assert_equal profile.medication_requests.length, 1
    assert_equal profile.medication_statements.length, 1
    assert_equal profile.observations.length, 1
  end

  test 'should ignore fhir types not supported' do
    profile = profiles(:harrys_profile)
    provider = providers(:partners)
    load_unsupported_resources(profile, provider)
    assert_equal 2, profile.resources.where(merged: false).count
    merger = HDM::Merge::Merger.new
    # called multiple times to simulate updating the profile more than once
    begin
      merger.update_profile(profile)
    rescue StandardError
      assert false, 'Falied to merge properly with unsupported resource types'
    end
  end

  private

  def load_resources(profile, provider)
    dr = DataReceipt.new(profile: profile, provider: provider, data: {}, data_type: 'fhir')
    dr.save
    types = [AllergyIntolerance, Device, CarePlan, Condition, Encounter, Goal,
             Immunization, MedicationAdministration, MedicationRequest, MedicationStatement,
             Observation, Procedure]
    types.each do |type|
      snake = type.name.underscore
      res = Resource.new(data_receipt: dr, provider: provider, profile: profile,
                         resource: parse_test_file("#{snake.pluralize}/#{snake}_good.json"),
                         resource_type: snake, provider_resource_id: 1, provider_resource_version: '')
      assert res.save, "Expected resource to save #{res.errors.messages}"
    end
  end

  def load_unsupported_resources(profile, provider)
    dr = DataReceipt.new(profile: profile, provider: provider, data: {}, data_type: 'fhir')
    dr.save
    files = Dir['./test/fixtures/files/unsupported/*.json']
    files.each do |file|
      resource = JSON.parse(File.read(file))
      snake = resource['resourceType'].underscore
      res = Resource.new(data_receipt: dr, provider: provider, profile: profile,
                         resource: resource,
                         resource_type: snake, provider_resource_id: 1, provider_resource_version: '')
      assert res.save, "Expected resource to save #{res.errors.messages}"
    end
  end
end
