require "rails_helper"

RSpec.describe Membership, type: :model do
  describe "validations" do
    it "is valid with owner role" do
      expect(build(:membership, :owner)).to be_valid
    end

    it "is valid with member role" do
      expect(build(:membership)).to be_valid
    end

    it "is invalid with an unknown role" do
      expect { build(:membership, role: :admin) }.to raise_error(ArgumentError)
    end

    it "enforces uniqueness of user per organization" do
      membership = create(:membership)
      duplicate = build(:membership, user: membership.user, organization: membership.organization)
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:owner_membership) { create(:membership, :owner) }
    let!(:member_membership) { create(:membership) }

    it "filters owners" do
      expect(Membership.owner).to include(owner_membership)
      expect(Membership.owner).not_to include(member_membership)
    end

    it "filters members" do
      expect(Membership.member).to include(member_membership)
      expect(Membership.member).not_to include(owner_membership)
    end
  end
end
