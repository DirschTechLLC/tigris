require "rails_helper"

RSpec.describe SubmissionsMailer, type: :mailer do
  let(:organization) { create(:organization, name: "Acme Inc") }
  let(:user) { create(:user, name: "Jane", email_address: "jane@example.com") }
  let(:api_key_record) { create(:api_key, organization: organization) }
  let(:submission) do
    create(:submission,
      organization: organization,
      api_key: api_key_record,
      payload: { "email" => "visitor@example.com", "name" => "Bob", "message" => "Hi" })
  end

  subject(:mail) { described_class.notify(user, submission) }

  it "is addressed to the user" do
    expect(mail.to).to eq(["jane@example.com"])
  end

  it "includes the organization name in the subject" do
    expect(mail.subject).to include("Acme Inc")
  end

  it "includes the submitter name in the body" do
    expect(mail.body.encoded).to include("Bob")
  end

  it "includes the submitter email in the body" do
    expect(mail.body.encoded).to include("visitor@example.com")
  end

  it "greets the recipient by name" do
    expect(mail.body.encoded).to include("Jane")
  end
end
