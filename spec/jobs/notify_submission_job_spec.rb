require "rails_helper"

RSpec.describe NotifySubmissionJob, type: :job do
  let(:organization) { create(:organization) }
  let(:api_key_record) { create(:api_key, organization: organization) }
  let(:submission) { create(:submission, organization: organization, api_key: api_key_record) }

  describe "#perform" do
    let!(:member1) { create(:user) }
    let!(:member2) { create(:user) }

    before do
      create(:membership, user: member1, organization: organization)
      create(:membership, user: member2, organization: organization)
    end

    it "sends one email per organization member" do
      expect {
        described_class.perform_now(submission.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it "discards the job when the submission no longer exists" do
      expect {
        described_class.perform_now(-1)
      }.not_to raise_error
    end
  end
end
