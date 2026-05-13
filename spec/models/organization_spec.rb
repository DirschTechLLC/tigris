require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it "requires a name" do
      org = build(:organization, name: nil)
      expect(org).not_to be_valid
      expect(org.errors[:name]).to be_present
    end

    it "generates a slug from name on create" do
      org = create(:organization, name: "Hello World")
      expect(org.slug).to eq("hello-world")
    end

    it "does not override a provided slug" do
      org = create(:organization, name: "My Org", slug: "custom-slug")
      expect(org.slug).to eq("custom-slug")
    end
  end

  describe "dependent destroy" do
    let(:organization) { create(:organization) }

    it "destroys memberships when the organization is destroyed" do
      create(:membership, organization: organization)
      expect { organization.destroy }.to change(Membership, :count).by(-1)
    end

    it "destroys api_keys when the organization is destroyed" do
      create(:api_key, organization: organization)
      expect { organization.destroy }.to change(ApiKey, :count).by(-1)
    end

    it "destroys submissions when the organization is destroyed" do
      create(:submission, organization: organization, api_key: create(:api_key, organization: organization))
      expect { organization.destroy }.to change(Submission, :count).by(-1)
    end
  end

  describe "#owner?" do
    let(:organization) { create(:organization) }
    let(:owner)    { create(:user) }
    let(:member)   { create(:user) }
    let(:outsider) { create(:user) }

    before do
      create(:membership, :owner, user: owner, organization: organization)
      create(:membership, user: member, organization: organization)
    end

    it { expect(organization.owner?(owner)).to be true }
    it { expect(organization.owner?(member)).to be false }
    it { expect(organization.owner?(outsider)).to be false }
  end

  describe "#member?" do
    let(:organization) { create(:organization) }
    let(:member)   { create(:user) }
    let(:outsider) { create(:user) }

    before { create(:membership, user: member, organization: organization) }

    it { expect(organization.member?(member)).to be true }
    it { expect(organization.member?(outsider)).to be false }
  end
end
