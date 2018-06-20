# frozen_string_literal: true

require 'test_helper'

class ConditionTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new condition' do
    p = profiles(:harrys_profile)
    create_new_success(Condition, p, read_test_file("conditions/condition_good.json"))
  end
end
