# frozen_string_literal: true

require 'test_helper'

class CuratedModelTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new resources' do
    p = profiles(:harrys_profile)
    types = [AllergyIntolerance, CarePlan, Condition, Device, Encounter, Goal,
             Immunization, MedicationAdministration, MedicationRequest, MedicationStatement,
             Observation, Procedure]
    types.each do |type|
      begin
        puts "Testing create #{type}"
        snake = type.name.underscore
        create_new_success(type, p, read_test_file("#{snake.pluralize}/#{snake}_good.json"))
      rescue StandardError
        assert false, "Error testing #{type} #{$!}"
      end
    end
  end


  test 'Should validate resource for wrong type' do
    p = profiles(:harrys_profile)
    types = [AllergyIntolerance, CarePlan, Condition, Device, Encounter, Goal,
             Immunization, MedicationAdministration, MedicationRequest, MedicationStatement,
             Observation, Procedure]
    types.each do |type|
      begin
        puts "Testing resourceType #{type}"

        mod = type.new(profile: p, resource: read_test_file("bundles/search-set.json"))
        assert_equal false, mod.valid? , "Should not be valid with wrond resource type"
        errors = mod.errors
        assert_equal errors["resource"], ["Wrong resource type: expected #{type.name} was Bundle"]
      rescue StandardError
        assert false, "Error testing #{type} #{$!}"
      end
    end
  end

    test 'Should validate resource based on fhir structure' do
      p = profiles(:harrys_profile)
      # Device
      types = [AllergyIntolerance, CarePlan, Condition, Encounter, Goal,
               Immunization, MedicationAdministration, MedicationRequest, MedicationStatement,
               Observation, Procedure]
      types.each do |type|
        begin
          puts "Testing invalid resource for  #{type}"
          snake = type.name.underscore
          mod = type.new(profile: p, resource: read_test_file("#{snake.pluralize}/#{snake}_bad.json"))
          mod.valid?
          errors = mod.errors
          assert_equal false, mod.valid? , "Should not be valid with invalid fhir resource"
          assert errors["resource_errors"].length > 0, "Resource validation errors should be greater than 0 for #{type}"
        rescue StandardError
          assert false, "Error testing #{type} #{$!}"
        end
      end
    end
end
