require "securerandom"

RSpec.describe SmartId::Utils::VerificationCodeCalculator do

  describe ".calculate" do
    it "always provides a 4 digit string" do
      data = SecureRandom.alphanumeric(32)
      expect(described_class.calculate(data).length).to eq(4)
    end

    it "consistenly provides same 4 digits for the same data" do
      expect(described_class.calculate("Somesampledata")).to eq("0222")
    end 
  end
end