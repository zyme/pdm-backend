# frozen_string_literal: true

class DataReceipt < ApplicationRecord
  belongs_to :provider
  belongs_to :profile
  has_many :resources, dependent: :destroy

  def process!
    return if processed

    fhir = FhirUtilities.new.fhir
    bundle = fhir.from_contents(data.is_a?(String) ? data : JSON.unparse(data))
    
    bundle.entry.each do |entry|
      # sometimes nil shows up here for some reason
      next unless entry

      fhir_resource = entry.resource
      # if this isn't a resource (OperationOutcome for instance) do nothing
      next unless fhir_resource.id

      # default to version 0 if no meta/versionId given
      resource_version = fhir_resource&.meta&.versionId || 0

      # don't insert duplicates
      duplicate_found = false
      potential_duplicates = Resource.where(profile: profile,
                                            provider: provider,
                                            provider_resource_id: fhir_resource.id,
                                            provider_resource_version: resource_version,
                                            resource_type: fhir_resource.resourceType)

      # for each potential duplicate, check if the resource hashes are equal, break if duplicate found   
      jfhir_resource = JSON.parse(fhir_resource.to_json)
      potential_duplicates.each do | duplicate |
        jduplicate = duplicate.resource
        if jduplicate == jfhir_resource
          duplicate_found = true
          break
        end
      end

      next if duplicate_found

      app_resource = Resource.new(profile: profile,
                                  provider: provider,
                                  data_receipt: self,
                                  resource_type: fhir_resource.resourceType,
                                  provider_resource_id: fhir_resource.id,
                                  provider_resource_version: resource_version,
                                  # data_specification_version # TODO: defaults to ""
                                  resource: fhir_resource,
                                  created_at: Time.now.utc,
                                  updated_at: Time.now.utc)

      app_resource.save!
    end

    self.processed = true
    self.processed_time = Time.now.utc
    save!
  end
end
