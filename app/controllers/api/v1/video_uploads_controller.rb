module Api
  module V1
    class VideoUploadsController < BaseController
      def index
        render json: model_scope
      end

      def show
        render json: record
      end

      def create
        record = current_user.video_uploads.create!(record_params)
        render json: record, status: :created
      end

      def destroy
        record.destroy!
        head :no_content
      end

      private

      def record
        model_scope.find(params[:id])
      end

      def model_scope
        current_user.video_uploads
      end

      def record_params
        params.permit(:from_seconds, :to_seconds, :input_file)
      end
    end
  end
end
