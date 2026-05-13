module Api
  module V1
    class SubmissionsController < Api::BaseController
      MAX_PAYLOAD_BYTES = 64.kilobytes

      def create
        payload = submission_payload

        if payload.to_json.bytesize > MAX_PAYLOAD_BYTES
          render json: { error: "Payload too large" }, status: :unprocessable_entity
          return
        end

        submission = current_organization.submissions.build(
          api_key: @current_api_key,
          payload: payload,
          remote_ip: request.remote_ip,
          user_agent: request.user_agent,
          referrer: request.referer
        )

        if submission.save
          NotifySubmissionJob.perform_later(submission.id)
          render json: { status: "ok" }, status: :created
        else
          render json: { errors: submission.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def submission_payload
        params.except(:controller, :action, :format).to_unsafe_h
      end
    end
  end
end
