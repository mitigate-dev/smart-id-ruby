RSpec.describe SmartId do


  it "has a version number" do
    expect(SmartId::VERSION).not_to be nil
  end

  describe ".configure" do
    let(:relying_party_uuid) { "test_uuid "}
    let(:relying_party_name) { "test_name" }
    let(:default_certificate_level) { "ADVANCED" }
    let(:host_url) { "http://test.com" }

    before do
      described_class.configure do |config|
        config.relying_party_uuid = relying_party_uuid
        config.relying_party_name = relying_party_name
        config.default_certificate_level = default_certificate_level
        config.environment = "demo"
      end
    end

    it "can set configuration" do
      expect(described_class.relying_party_uuid).to eq(relying_party_uuid)
      expect(described_class.relying_party_name).to eq(relying_party_name)
      expect(described_class.default_certificate_level).to eq(default_certificate_level)
    end
  end
end
