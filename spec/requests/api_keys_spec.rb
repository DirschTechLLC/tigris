require "rails_helper"

RSpec.describe "ApiKeys", type: :request do
  let(:owner) { create(:user) }
  let(:member_user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:membership, :owner, user: owner, organization: organization)
    create(:membership, user: member_user, organization: organization)
  end

  describe "POST /organizations/:organization_slug/api_keys" do
    context "as an owner" do
      before { sign_in(owner) }

      it "creates an API key and redirects" do
        expect {
          post organization_api_keys_path(organization), params: { api_key: { name: "Production" } }
        }.to change { organization.api_keys.count }.by(1)

        expect(response).to redirect_to(organization_api_keys_path(organization))
      end
    end

    context "as a member (not owner)" do
      before { sign_in(member_user) }

      it "redirects without creating" do
        expect {
          post organization_api_keys_path(organization), params: { api_key: { name: "Production" } }
        }.not_to change(ApiKey, :count)
      end
    end
  end

  describe "DELETE /organizations/:organization_slug/api_keys/:id" do
    let!(:api_key_record) { create(:api_key, organization: organization) }

    context "as an owner" do
      before { sign_in(owner) }

      it "revokes the key" do
        delete organization_api_key_path(organization, api_key_record)
        expect(api_key_record.reload.active).to be false
      end
    end

    context "as a member (not owner)" do
      before { sign_in(member_user) }

      it "does not revoke the key" do
        delete organization_api_key_path(organization, api_key_record)
        expect(api_key_record.reload.active).to be true
      end
    end
  end
end
