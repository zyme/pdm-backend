# frozen_string_literal: true

require 'test_helper'

class ImmunizationTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new condition' do
    p = profiles(:harrys_profile)
    create_new_success(Immunization, p, read_test_file('immunizations/immunization_good.json'))
  end
end
