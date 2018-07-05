# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PatientsControllerTest < ActionDispatch::IntegrationTest
      test 'user should be able to get their own patient record' do
        user = users(:harry)
        token = generate_token(user.id)
        profile = user.profiles.first
        get "/api/v1/Patient/#{profile.id}", params: { access_token: token.token }
        assert_response :success

        patient = FHIR::Json.from_json(@response.body)
        assert_not_nil(patient)
        assert_equal('Patient', patient.resourceType)
        assert_equal(profile.id, patient.id)
        assert_equal(profile.gender, patient.gender)
        assert_equal(profile.first_name, patient.name[0].given[0])
        assert_equal(profile.last_name, patient.name[0].family)
      end

      test 'user should be able to get $everything on their own patient record' do
        user = users(:harry)
        token = generate_token(user.id)
        profile = profiles(:jills_profile)
        get "/api/v1/Patient/#{profile.id}/$everything", params: { access_token: token.token }
        assert_response :success

        bundle = FHIR::Json.from_json(@response.body)
        assert_not_nil(bundle)
        assert_equal('Bundle', bundle.resourceType)
        assert_equal(3, bundle.entry.size)

        patient = bundle.entry[0].resource
        assert_equal('Patient', patient.resourceType)

        assert_equal(profile.first_name, patient.name[0].given[0])
        assert_equal(profile.last_name, patient.name[0].family)

        condition = bundle.entry[1].resource
        assert_equal('Condition', condition.resourceType)
        assert_equal('Q84.1', condition.code.coding[0].code)

        condition = bundle.entry[2].resource
        assert_equal('Condition', condition.resourceType)
        assert_equal('W61.62', condition.code.coding[0].code)
      end

      test 'user should be able to see all patient records they have access to' do
        user = users(:harry)
        token = generate_token(user.id)

        get '/api/v1/Patient', params: { access_token: token.token }
        assert_response :success

        bundle = FHIR::Json.from_json(@response.body)
        assert_not_nil(bundle)
        assert_equal('Bundle', bundle.resourceType)
        assert_equal(2, bundle.entry.size)

        entries = bundle.entry.map(&:resource).sort_by(&:id)

        assert_equal('Harry', entries[0].name[0].given[0])
        assert_equal('Sotired', entries[0].name[0].family)

        assert_equal('Jill', entries[1].name[0].given[0])
        assert_equal('Sotired', entries[1].name[0].family)
      end

      test 'user should not be able to see someone elses patient record' do
        user = users(:harry)
        token = generate_token(user.id)

        someone_else = users(:sema)
        profile = someone_else.profiles.first

        get "/api/v1/Patient/#{profile.id}", params: { access_token: token.token }
        assert_response :missing
      end
    end
  end
end
