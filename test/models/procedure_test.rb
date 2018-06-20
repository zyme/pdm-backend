# frozen_string_literal: true

require 'test_helper'

class ProcedureTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new procedure' do
    p = profiles(:harrys_profile)
    create_new_success(Procedure, p, read_test_file("procedures/procedure_good.json"))
  end
end
