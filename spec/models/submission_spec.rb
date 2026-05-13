require "rails_helper"

RSpec.describe Submission, type: :model do
  describe "validations" do
    it "is valid with an email in the payload" do
      expect(build(:submission)).to be_valid
    end

    it "is invalid without an email in the payload" do
      expect(build(:submission, payload: { "name" => "Test" })).not_to be_valid
    end

    it "is invalid with an empty payload" do
      expect(build(:submission, payload: {})).not_to be_valid
    end
  end

  describe ".recent" do
    subject(:scope) { described_class.recent }

    let!(:older) { create(:submission, created_at: 1.hour.ago) }
    let!(:newer) { create(:submission) }

    it "orders newest first" do
      expect(scope.first).to eq(newer)
      expect(scope.last).to eq(older)
    end
  end
end
