# frozen_string_literal: true

require 'uuid'
module CuratedModel
  extend ActiveSupport::Concern
  include FHIRWrapper

  included do
    validates :resource, presence: true
    validate do
      # errors.add :resource_errors, fhir_model.validate unless fhir_model.valid?
      errors.add :resource, "Wrong resource type: expected #{self.class.name} was #{fhir_model.resourceType}" unless fhir_model.resourceType == self.class.name
    end
    # update the underlying json model with the current
    before_save do
      generate_resource_id if new_record? && resource_id.nil?
      fhir_model.id = resource_id
      update_resource
      self.resource = fhir_model.as_json
    end
  end

  # empty method, should be implemented in classes
  def update_resource
    fhir_manager = FhirUtilities.new
    fhir = fhir_manager.fhir
    if fhir_model.respond_to? :patient
      fhir_model.patient = fhir::Reference.new(reference: profile.reference)
    elsif fhir_model.respond_to? :subject
      fhir_model.subject = fhir::Reference.new(reference: profile.reference)
    end
  end

  private

  def generate_resource_id
    self.resource_id = UUID.generate
  end
end
