# frozen_string_literal: true

module Api
  module V1
    class ProvidersController < ApiController
      def index
        render json: Provider.all, status: :ok
      end

      def show
        render json: Provider.find(params[:id]), status: :ok
      end
    end
  end
end
