
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "hdm/oauth/state"
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
