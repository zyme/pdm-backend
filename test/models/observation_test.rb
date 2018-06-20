# frozen_string_literal: true

require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new observation' do
    p = profiles(:harrys_profile)
    create_new_success(Observation, p, read_test_file("observations/observation_good.json"))
  end
end
