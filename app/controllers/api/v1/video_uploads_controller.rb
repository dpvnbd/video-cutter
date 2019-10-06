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
        VideoCutterWorker.perform_async(record.id)
        render json: record, status: :created
      end

      def restart
        if record.restart_allowed?
          VideoCutterWorker.perform_async(record.id)
          render json: record
        else
          render json: { errors: [I18n.t(:restart_forbidden)] }, status: :bad_request

        end
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
