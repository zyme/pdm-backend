# frozen_string_literal: true

require 'test_helper'

class MedicationAdministrationTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new medication administration' do
    p = profiles(:harrys_profile)
    create_new_success(MedicationAdministration, p, read_test_file('medication_administrations/medication_administration_good.json'))
  end
end
