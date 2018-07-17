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

        resource = resources(:imperfect_match_resource)
        json = JSON.parse(resource.resource)
        matches = GenericMatcher.match(json, relationship)
        assert_equal(1, matches.length)
      end

      test 'should correctly identify non-matching resource' do
        profile = profiles(:jills_profile)
        relationship = profile.conditions

        resource = resources(:unmatching_resource)
        json = JSON.parse(resource.resource)
        matches = GenericMatcher.match(json, relationship)
        assert_empty(matches)
      end
    end
  end
end
