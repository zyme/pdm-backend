# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CuratedModelsControllerTest < ActionDispatch::IntegrationTest
      test 'user should be able to get conditions for their profile' do
        user = users(:harry)
        token = generate_token(user.id)
        profile = user.profiles.first

        get "/api/v1/profiles/#{profile.id}/conditions", params: { access_token: token.token }
        assert_response :success
      end

      test 'user should be able to get conditions for their profile via FHIR API' do
        user = users(:harry)
        token = generate_token(user.id)

        get '/api/v1/Condition', params: { access_token: token.token }
        assert_response :success

        bundle = FHIR::Json.from_json(@response.body)
        assert_not_nil(bundle)
        assert_equal(2, bundle.entry.size)

        codes = bundle.entry.map { |e| e.resource.code.coding[0].code }.sort
        assert_equal('Q84.1', codes[0])
        assert_equal('W61.62', codes[1])
      end

      test 'user should not be able to get conditions for someone else' do
        user = users(:harry)
        token = generate_token(user.id)

        someone_else = users(:sema)
        profile = someone_else.profiles.first

        get "/api/v1/profiles/#{profile.id}/conditions", params: { access_token: token.token }
        assert_response :missing
      end

      test 'user should not be able to get conditions for someone else via FHIR API' do
        user = users(:harry)
        token = generate_token(user.id)

        someone_else = users(:sema)
        profile = someone_else.profiles.first
        condition = profile.conditions.first

        get "/api/v1/Condition/#{condition.id}", params: { access_token: token.token }
        assert_response :missing
      end
    end
  end
end
