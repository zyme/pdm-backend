# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class BaseControllerTest < ActionDispatch::IntegrationTest
      test 'should be able to post EDR bundle' do
        user = users(:harry)
        profile = user.profiles.first

        provider = providers(:bwh)
        app = generate_application(provider)
        token = generate_app_token(app.id)

        bundle_json = load_bundle('Harris789_Stark857_2159d1ae-e556-4533-978d-be1f9812607d')
        # hardcoding the ID caused some issues with other tests so we have to manually set it in the bundle
        bundle_json.gsub!('BASE_CONTROLLER_TEST_PLACEHOLDER_ID', profile.id.to_s)

        post '/api/v1/', params: bundle_json, headers: { authorization: "Bearer #{token.token}" }
        assert_response :created

        assert DataReceipt.find_by(profile_id: profile.id, provider_id: provider.id)
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
