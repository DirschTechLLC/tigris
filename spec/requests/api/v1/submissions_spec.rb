require "rails_helper"

RSpec.describe "API::V1::Submissions", type: :request do
  let(:organization) { create(:organization) }
  let!(:api_key_record) { create(:api_key, organization: organization) }
  let(:raw_token) { "tgk_#{SecureRandom.hex(4)}#{SecureRandom.hex(16)}" }

  before do
    api_key_record.update!(
      prefix: raw_token[0, 12],
      token_digest: Digest::SHA256.hexdigest(raw_token)
    )
  end

  let(:valid_payload) { { email: "test@example.com", name: "Test User", message: "Hello" } }

  describe "POST /api/v1/submissions" do
    context "with a valid API key and payload" do
      it "returns 201 and creates a submission" do
        expect {
          api_post "/api/v1/submissions", raw_token: raw_token, params: valid_payload
        }.to change(Submission, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["status"]).to eq("ok")
      end

      it "enqueues NotifySubmissionJob" do
        expect {
          api_post "/api/v1/submissions", raw_token: raw_token, params: valid_payload
        }.to have_enqueued_job(NotifySubmissionJob)
      end

      it "stores metadata on the submission" do
        api_post "/api/v1/submissions", raw_token: raw_token, params: valid_payload
        submission = Submission.last
        expect(submission.remote_ip).to be_present
        expect(submission.organization).to eq(organization)
        expect(submission.api_key).to eq(api_key_record)
      end
    end

    context "with a missing API key" do
      it "returns 401" do
        post "/api/v1/submissions", params: valid_payload, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an invalid API key" do
      it "returns 401" do
        api_post "/api/v1/submissions", raw_token: "tgk_invalid", params: valid_payload
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a revoked API key" do
      before { api_key_record.revoke! }

      it "returns 401" do
        api_post "/api/v1/submissions", raw_token: raw_token, params: valid_payload
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a payload missing email" do
      it "returns 422" do
        api_post "/api/v1/submissions", raw_token: raw_token, params: { name: "Test" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "cross-org isolation" do
      let(:other_org) { create(:organization) }
      let(:other_key_record) { create(:api_key, organization: other_org) }
      let(:other_raw_token) { "tgk_#{SecureRandom.hex(4)}#{SecureRandom.hex(16)}" }

      before do
        other_key_record.update!(
          prefix: other_raw_token[0, 12],
          token_digest: Digest::SHA256.hexdigest(other_raw_token)
        )
      end

      it "scopes submissions to the resolved organization" do
        api_post "/api/v1/submissions", raw_token: other_raw_token, params: valid_payload
        expect(Submission.last.organization).to eq(other_org)
      end
    end
  end
end
