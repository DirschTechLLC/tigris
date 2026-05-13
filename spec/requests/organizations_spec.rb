require "rails_helper"

RSpec.describe "Organizations", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "POST /organizations" do
    it "creates the organization and an owner membership atomically" do
      expect {
        post organizations_path, params: { organization: { name: "Acme Inc" } }
      }.to change(Organization, :count).by(1).and change(Membership, :count).by(1)

      org = Organization.last
      expect(org.owner?(user)).to be true
    end

    it "redirects to submissions after creation" do
      post organizations_path, params: { organization: { name: "Acme Inc" } }
      expect(response).to redirect_to(organization_submissions_path(Organization.last))
    end
  end

  describe "PATCH /organizations/:slug" do
    let(:organization) { create(:organization) }

    context "as an owner" do
      before { create(:membership, :owner, user: user, organization: organization) }

      it "updates the organization name" do
        patch organization_path(organization), params: { organization: { name: "New Name" } }
        expect(organization.reload.name).to eq("New Name")
      end
    end

    context "as a member (not owner)" do
      before { create(:membership, user: user, organization: organization) }

      it "does not update" do
        patch organization_path(organization), params: { organization: { name: "New Name" } }
        expect(organization.reload.name).not_to eq("New Name")
      end
    end
  end
end
