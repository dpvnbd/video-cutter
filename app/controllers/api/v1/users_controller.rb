module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: :create

      def create
        user = User.create!
        render json: user, status: :created
      end
    end
  end
end
