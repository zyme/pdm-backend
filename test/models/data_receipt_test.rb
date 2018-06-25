# frozen_string_literal: true

require 'test_helper'

class DataReceiptTest < ActiveSupport::TestCase
  include ResourceTestHelper

  setup do
    clear
  end

  teardown do
    clear
  end

  def clear
    provider = providers(:partners)
    DataReceipt.where(provider: provider).destroy_all
  end

  test 'Data Receipt must process successfully for good data' do
    profile = profiles(:harrys_profile)
    provider = providers(:partners)
    json = read_test_file('bundles/search-set.json')
    dr = DataReceipt.new(profile: profile, provider: provider, data: json, data_type: 'fhir')
    dr.process!

    assert_equal(50, dr.resources.count)
  end

  test 'Data Receipt must only be processed once' do
    profile = profiles(:harrys_profile)
    provider = providers(:partners)
    json = read_test_file('bundles/search-set.json')
    dr = DataReceipt.new(profile: profile, provider: provider, data: json, data_type: 'fhir', processed: true)
    dr.process!

    # we said it's already processed so it shouldn't insert anything
    assert_equal(0, dr.resources.count)
  end

  test 'Data Receipt should not insert duplicates' do
    profile = profiles(:harrys_profile)
    provider = providers(:partners)
    json = read_test_file('bundles/search-set.json')
    dr = DataReceipt.new(profile: profile, provider: provider, data: json, data_type: 'fhir')
    dr.process!

    assert_equal(50, dr.resources.count)

    dr = DataReceipt.new(profile: profile, provider: provider, data: json, data_type: 'fhir')
    dr.process!

    # everything is a dup so it shouldn't insert anything
    assert_equal(0, dr.resources.count)
  end

  test "Transaction must be associated with a profile" do
    provider = providers(:partners)
    json = read_test_file('bundles/search-set.json')
    dr = DataReceipt.new(provider: provider, data: json, data_type: 'fhir')

    refute(dr.save)
    assert_not_nil(dr.errors)
  end
  
  test "Transaction must be associated with a provider" do
    profile = profiles(:harrys_profile)
    json = read_test_file('bundles/search-set.json')
    dr = DataReceipt.new(profile: profile, data: json, data_type: 'fhir')

    refute(dr.save)
    assert_not_nil(dr.errors)
  end
end
