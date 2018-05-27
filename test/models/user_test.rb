require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "user can have multiple profiles" do
    user = users(:harry)
    assert user.profiles.length > 1
  end

  test "default profile created when user is created" do

  end
end
