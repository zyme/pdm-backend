# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'hdm'
require 'rails/test_help'
require 'hdm/oauth/state'
FHIR.logger.level = 'ERROR'
class ActionDispatch::IntegrationTest
  def generate_token(user_id)
    token = Doorkeeper::AccessToken.new(resource_owner_id: user_id)
    token.save!
    token
  end
end

class ActiveSupport::TestCase
  fixtures :all
end

module ResourceTestHelper
  def assert_patient_or_subject(mod)
    if mod.respond_to? :patient
      assert_equal mod.fhir_model.patient.reference, profile.reference, 'Should update patient id'
    elsif mod.respond_to? :subject
      assert_equal mod.fhir_model.subject.reference, profile.reference, 'Should update patient id'
    end
  end

  def read_test_file(file)
    File.read(File.join('./test/fixtures/files', file))
  end

  def parse_test_file(file)
    JSON.parse(read_test_file(file))
  end

  def create_new_success(klass, profile, data)
    mod = klass.new(profile: profile, resource: data)
    assert mod.valid?, "Model should be valid: #{klass} #{mod.errors.messages}"
    assert mod.save
    assert_patient_or_subject mod
    assert_equal mod.fhir_model.id, mod.resource_id, 'Should update resource id'
  end
end

# Monkey patch to fix a FakeWeb issue with newer versions of Ruby - Ruby now
# auto-closes sockets and FakeWeb's sockets have no close method
require 'fakeweb'
module MonkeyPatch
  module FakeWeb
    module StubSocketFixes
      def close
      end
    end
  end
end

FakeWeb::StubSocket.include MonkeyPatch::FakeWeb::StubSocketFixes