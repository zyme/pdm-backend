module Api

  module V1
    class UsersController < ApiController

      def show
        render json: current_resource_owner, status: 200
      end

    end
  end

end
