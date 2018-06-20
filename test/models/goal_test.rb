# frozen_string_literal: true

require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new goal' do
    p = profiles(:harrys_profile)
    create_new_success(Goal, p, read_test_file("goals/goal_good.json"))
  end
end
