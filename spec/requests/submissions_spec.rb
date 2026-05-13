require "rails_helper"

RSpec.describe "Submissions", type: :request do
  let(:owner) { create(:user) }
  let(:organization) { create(:organization) }

  before { create(:membership, :owner, user: owner, organization: organization) }

  describe "GET /organizations/:organization_slug/submissions" do
    context "when authenticated as a member" do
      before { sign_in(owner) }

      it "returns 200" do
        get organization_submissions_path(organization)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when unauthenticated" do
      it "redirects to login" do
        get organization_submissions_path(organization)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated but not a member" do
      before { sign_in(create(:user)) }

      it "returns 404" do
        get organization_submissions_path(organization)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /organizations/:organization_slug/submissions/:id" do
    let(:api_key_record) { create(:api_key, organization: organization) }
    let(:submission) { create(:submission, organization: organization, api_key: api_key_record) }
    let(:other_org) { create(:organization) }
    let(:other_key) { create(:api_key, organization: other_org) }
    let(:other_submission) { create(:submission, organization: other_org, api_key: other_key) }

    before { sign_in(owner) }

    it "returns 200 for own submission" do
      get organization_submission_path(organization, submission)
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for another org's submission by ID" do
      get organization_submission_path(organization, other_submission)
      expect(response).to have_http_status(:not_found)
    end
  end
end
