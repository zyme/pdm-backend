# frozen_string_literal: true

require 'test_helper'

class MedicationStatementTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new medication statement' do
    p = profiles(:harrys_profile)
    create_new_success(MedicationStatement, p, read_test_file('medication_statements/medication_statement_good.json'))
  end
end
