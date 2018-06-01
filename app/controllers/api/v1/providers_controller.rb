module Api
  module V1
    class ProvidersController < ApiController

      def index
        render json: Provider.all , status: 200
      end

      def show
        render json: Provider.find(params[:id]) , status: 200
      end

    end
  end
end
