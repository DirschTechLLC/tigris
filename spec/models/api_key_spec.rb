require "rails_helper"

RSpec.describe ApiKey, type: :model do
  describe ".authenticate" do
    let(:organization) { create(:organization) }
    let(:valid_raw) { "tgk_abcd1234#{SecureRandom.hex(16)}" }

    before do
      organization.api_keys.create!(
        name: "Test",
        prefix: valid_raw[0, 12],
        token_digest: Digest::SHA256.hexdigest(valid_raw)
      )
    end

    context "with a valid token" do
      subject(:key) { described_class.authenticate(valid_raw) }

      it { is_expected.to be_an(ApiKey) }

      it "touches last_used_at" do
        expect(key.last_used_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context "with an invalid token" do
      subject { described_class.authenticate("tgk_totallywrong") }
      it { is_expected.to be_nil }
    end

    context "with a revoked key" do
      before { organization.api_keys.first.revoke! }
      subject { described_class.authenticate(valid_raw) }
      it { is_expected.to be_nil }
    end

    context "with a blank token" do
      subject { described_class.authenticate("") }
      it { is_expected.to be_nil }
    end
  end

  describe ".generate_for" do
    subject(:result) { described_class.generate_for(organization, name: "Production") }

    let(:organization) { create(:organization) }

    it "returns a key and a raw token" do
      key, raw = result
      expect(key).to be_a(ApiKey)
      expect(raw).to start_with("tgk_")
    end

    it "does not store the raw token" do
      key, raw = result
      expect(key.token_digest).not_to eq(raw)
    end

    it "stores a SHA-256 digest" do
      key, raw = result
      expect(key.token_digest).to eq(Digest::SHA256.hexdigest(raw))
    end

    it "stores the prefix" do
      key, raw = result
      expect(raw).to start_with(key.prefix)
    end
  end

  describe "#revoke!" do
    subject(:api_key) { create(:api_key) }

    it "sets active to false" do
      expect { api_key.revoke! }.to change { api_key.active }.from(true).to(false)
    end
  end
end
