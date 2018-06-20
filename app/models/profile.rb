# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  has_many :profile_providers
  has_many :providers, through: :profile_providers
  validates :name, presence: true

  has_many :allergies
  has_many :care_plans
  has_many :conditions
  has_many :devices
  has_many :documents
  has_many :encounters
  has_many :immunizations
  has_many :medication_administrations
  has_many :medication_requests
  has_many :medication_statements
  has_many :observations

  def has_provider?(provider_id)
    return false if provider_id.nil?
    !providers.find_by(id: provider_id).nil?
  end

  def reference
    "Patient/#{patient_id}"
  end
end
