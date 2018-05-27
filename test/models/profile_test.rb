require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  test "Profile must have a user and a name " do
    p = Profile.new()
    assert !p.valid?, "Profile should not be valid without a name or user"
    assert_equal p.errors[:user], ["must exist"]
    assert_equal p.errors[:name], ["can't be blank"]
    assert_equal p.errors.keys.length, 2
  end

  test "Can save Profile with a user and a name " do
    p = Profile.new(user: User.first, name: "Skippy")
    assert p.valid?, "Profile should  be valid with a name or user"
    assert p.save, "Profile should save with user and name "
  end

  test "Profile cannot link to the same provider twice " do
    pp = profile_providers(:harry_partners)
    new_pp = ProfileProvider.new({provider_id: pp.provider_id,
                              profile_id: pp.profile_id,
                              patient_id: "" })
                              
    assert !new_pp.valid? , "Provider Profile should not be valid if the profile is already linked to the provider"
    assert_equal new_pp.errors[:provider], ["already linked to this provider"]
  end

  test "Profile cannot link to provider if already linked to parent" do
    pp = profile_providers(:harry_partners)
    bwh = providers(:bwh)
    new_pp = ProfileProvider.new({provider_id: bwh.id,
                              profile_id: pp.profile_id,
                              patient_id: ""} )

    assert !new_pp.valid? , "Provider Profile should not be valid if the profile is already linked to the providers parent"
    assert_equal new_pp.errors[:provider], ["already linked to this provider through parent"]
  end

  test "Should be able to link to a provider" do
    pp = profile_providers(:harry_partners)
    fitbit = providers(:fitbit)
    new_pp = ProfileProvider.new({provider_id: fitbit.id,
                              profile_id: pp.profile_id,
                              patient_id: ""} )
    assert new_pp.valid? , "Should be able to link to a provider that is not already linked to"
    assert new_pp.save, "should be able to save profile provider when not already linked to"
  end
end
