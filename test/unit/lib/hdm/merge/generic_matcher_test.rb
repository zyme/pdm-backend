# frozen_string_literal: true

require 'test_helper'
require 'uri'
module HDM
  module Merge
    class GenericMatcherTest < ActiveSupport::TestCase
      include ResourceTestHelper

      test 'should correctly identify matching resources' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:perfect_match_resource)
        json = JSON.parse(resource.resource)
        match = GenericMatcher.match(json, relationship)
        expected = conditions(:uncombable_hair_syndrome)
        assert_equal(expected.resource, match[:right])

        resource = resources(:imperfect_match_resource)
        json = JSON.parse(resource.resource)
        match = GenericMatcher.match(json, relationship)
        expected = conditions(:uncombable_hair_syndrome)
        assert_equal(expected.resource, match[:right])
      end

      test 'should correctly exclude non-matching resource' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:unmatching_resource)
        json = JSON.parse(resource.resource)
        matches = GenericMatcher.match(json, relationship)
        assert_nil(matches)
      end

      test 'should not create operation outcome on perfect match' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:perfect_match_resource)
        json = JSON.parse(resource.resource)
        match = GenericMatcher.match(json, relationship)

        outcome = GenericMatcher.deconflict(resource, match)

        assert_nil outcome
      end

      test 'should create operation outcome for deconfliction on imperfect match' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:imperfect_match_resource)
        json = JSON.parse(resource.resource)
        match = GenericMatcher.match(json, relationship)

        expected = conditions(:uncombable_hair_syndrome)

        outcome = GenericMatcher.deconflict(resource, match)

        assert outcome.is_a? FHIR::OperationOutcome
        assert_equal(1, outcome.issue.length)
        issue = outcome.issue[0]
        assert_equal(1, issue.location.length) # only 1 field mismatched
        assert_equal('assertedDate', issue.location[0])

        assert_includes(issue.diagnostics, "Condition:#{expected.id}") # id of the matching curated model resource
        assert_includes(issue.diagnostics, "Resource:#{resource.id}") # id of the Resource itself
      end

      # lower level unit tests
      test 'datetimes should match if same day' do
        date1 = '2001-01-16T23:59:59-00:00'
        date2 = '2001-01-16T00:00:00-00:00'
        assert GenericMatcher.values_match?(date1, date2)
      end

      test 'datetimes should not match if different day' do
        date1 = '2001-01-16T23:59:59-00:00'
        date2 = '2001-01-17T00:00:00-00:00'
        assert_not GenericMatcher.values_match?(date1, date2)
      end

      test 'floats should match if within threshold' do
        f1 = 1.000001
        f2 = 1.00000
        assert GenericMatcher.values_match?(f1, f2)
      end

      test 'floats should not match if not within threshold' do
        f1 = 1.001
        f2 = 1.00
        assert_not GenericMatcher.values_match?(f1, f2)
      end
    end
  end
end
