RSpec.describe SmartId::AuthenticationCertificate::Content do
  let(:sample_cert) { "/C=EE/SN=SMART-ID/GN=DEMO/serialNumber=PNOEE-10101010005/CN=SMART-ID,DEMO,PNOEE-10101010005/OU=AUTHENTICATION" }
  subject { described_class.new(sample_cert) }
  # ["", "C=EE", "SN=SMART-ID", "GN=DEMO", "serialNumber=PNOEE-10101010005", "CN=SMART-ID,DEMO,PNOEE-10101010005", "OU=AUTHENTICATION"]

  describe "property methods" do
    it "returns various properties available in certificate" do
      expect(subject.country).to eq("EE")
      expect(subject.surname).to eq("SMART-ID")
      expect(subject.given_name).to eq("DEMO")
      expect(subject.identity_number).to eq("PNOEE-10101010005")
      expect(subject.all_info).to eq("SMART-ID,DEMO,PNOEE-10101010005")
      expect(subject.organizational_unit).to eq("AUTHENTICATION")
    end
  end
end