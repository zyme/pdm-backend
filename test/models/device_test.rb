# frozen_string_literal: true

require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new device' do
    p = profiles(:harrys_profile)
    create_new_success(Device, p, read_test_file('devices/device_good.json'))
  end
end
