# frozen_string_literal: true

class DataReceipt < ApplicationRecord
  belongs_to :provider
  belongs_to :profile
  has_many :resources, dependent: :destroy

  def process!
    return if processed

    bundle = FHIR.from_contents(data)
    bundle.entry.each do |entry|
      fhir_resource = entry.resource
      app_resource = Resource.new(user: profile.user,
                                  profile: profile,
                                  provider: provider,
                                  data_receipt: self,
                                  resource_type: fhir_resource.resourceType,
                                  provider_resource_id: fhir_resource.id,
                                  # default to version 0 if no meta/versionId given
                                  provider_resource_version: fhir_resource&.meta&.versionId || 0,
                                  # data_specification_version # TODO: defaults to ""
                                  resource: fhir_resource.to_json,
                                  created_at: Time.now.utc,
                                  updated_at: Time.now.utc)

      app_resource.save!
    end

    self.processed = true
    self.processed_time = Time.now.utc
    save!
  end
end
