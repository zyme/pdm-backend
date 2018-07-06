# frozen_string_literal: true

class ProfileProvider < ApplicationRecord
  belongs_to :provider
  belongs_to :profile
  validate :validates_profile_already_linked, :on => :create

  def validates_profile_already_linked
    if profile.has_provider? provider
      errors.add(:provider, 'already linked to this provider')
    elsif profile.has_provider? provider.parent
      errors.add(:provider, 'already linked to this provider through parent')
    end
  end
end
