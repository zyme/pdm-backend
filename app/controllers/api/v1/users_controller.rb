# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      def show
        render json: current_resource_owner, status: :ok
      end
    end
  end
end
