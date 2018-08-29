# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class BaseControllerTest < ActionDispatch::IntegrationTest
      test 'should be able to post EDR bundle' do
        profile = profiles(:harrys_profile)

        provider = providers(:bwh)
        app = generate_application(provider)
        token = generate_app_token(app.id)

        bundle_json = load_bundle('encounter_data_receipt')

        post '/api/v1/$process-message', params: bundle_json, headers: { authorization: "Bearer #{token.token}" }
        assert_response :ok

        assert DataReceipt.find_by(profile_id: profile.id, provider_id: provider.id)

        response_bundle = FHIR::Json.from_json(@response.body)

        assert_equal(1, response_bundle.entry.length)
        response_message = response_bundle.entry[0].resource
        assert_equal('MessageHeader', response_message.resourceType)
        assert_equal('6fc53664-8912-4b78-bd43-8d89eea7b651', response_message.response.identifier)
        assert_equal('ok', response_message.response.code)
      end

      def load_bundle(name)
        File.read("./test/fixtures/files/bundles/#{name}.json")
      end

      def generate_application(provider)
        app = Doorkeeper::Application.create(name: provider.name, redirect_uri: 'https://example.com')
        ProviderApplication.create(provider_id: provider.id, application_id: app.id)
        app
      end

      def generate_app_token(application_id)
        token = Doorkeeper::AccessToken.new(application_id: application_id)
        token.save!
        token
      end
    end
  end
end
