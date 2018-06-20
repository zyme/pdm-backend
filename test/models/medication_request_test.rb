# frozen_string_literal: true

require 'test_helper'

class MedicationRequestTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new medication request' do
    p = profiles(:harrys_profile)
    create_new_success(MedicationRequest, p, read_test_file('medication_requests/medication_request_good.json'))
  end
end
