module Api
  module V1
    class BaseController < ApplicationController
      include ApiKeyAuthorization
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      private

      def handle_record_not_found
        render status: :not_found, json: { errors: [I18n.t(:not_found)] }
      end

      def handle_record_invalid(exception)
        render status: :unprocessable_entity, json: { errors: exception.record.errors.full_messages }
      end
    end
  end
end
