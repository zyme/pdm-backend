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
        matches = GenericMatcher.match(json, relationship)
        assert_equal(1, matches.length)
        expected = conditions(:uncombable_hair_syndrome)
        assert_equal(expected, matches[0])

        resource = resources(:imperfect_match_resource)
        json = JSON.parse(resource.resource)
        matches = GenericMatcher.match(json, relationship)
        assert_equal(1, matches.length)
        expected = conditions(:uncombable_hair_syndrome)
        assert_equal(expected, matches[0])
      end

      test 'should correctly exclude non-matching resource' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:unmatching_resource)
        json = JSON.parse(resource.resource)
        matches = GenericMatcher.match(json, relationship)
        assert_empty(matches)
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
