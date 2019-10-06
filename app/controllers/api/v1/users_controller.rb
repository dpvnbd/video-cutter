module Api
  module V1
    class UsersController < BaseController
      def create
        user = User.create
        render json: user, status: :created
      end
    end
  end
end
