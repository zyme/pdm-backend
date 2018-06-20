# frozen_string_literal: true
require 'uuid'
module CuratedModel
  extend ActiveSupport::Concern

  included do
    validates :resource, presence: true
    validate do
      errors.add :resource, fhir_model.validate unless fhir_model.valid?
    end
    # update the underlying json model with the current
    before_save do
      if new_record? && resource_id.nil?
        generate_resource_id
      end
      fhir_model.id = resource_id
      update_resource
      self.resource = fhir_model.as_json
    end
  end

  def fhir_model
    @fhir_model ||= from_json
  end

  # empty method, should be implemented in classes
  def update_resource
    if fhir_model.respond_to? :patient
      fhir_model.patient = FHIR::Reference.new(reference: profile.reference)
    elsif fhir_model.respond_to? :subject
      fhir_model.subject = FHIR::Reference.new(reference: profile.reference)
    end
  end

  private

  def from_json
    resource_type = resource['resourceType']
    klass = Module.const_get("FHIR::#{resource_type}")
    klass.new(resource)
  end

  def generate_resource_id
    self.resource_id = UUID.generate
  end

end
