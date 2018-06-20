# frozen_string_literal: true

require 'test_helper'

class EncounterTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new Encounter' do
    p = profiles(:harrys_profile)
    create_new_success(Encounter, p, read_test_file("encounters/encounter_good.json"))
  end
end
