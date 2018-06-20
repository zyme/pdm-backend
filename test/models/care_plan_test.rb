# frozen_string_literal: true

require 'test_helper'

class CarePlanTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new care_plan' do
    p = profiles(:harrys_profile)
    create_new_success(CarePlan, p, read_test_file('care_plans/careplan_good.json'))
  end
end
