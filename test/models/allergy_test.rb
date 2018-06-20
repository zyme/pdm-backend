# frozen_string_literal: true

require 'test_helper'

class AllergyTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new allery' do
    p = profiles(:harrys_profile)
    create_new_success(Allergy, p, read_test_file("allergies/allergy_good.json"))
  end
end
