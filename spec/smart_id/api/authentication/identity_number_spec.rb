RSpec.describe SmartId::Api::Authentication::IdentityNumber do
  let(:successful_data) { {country: "EE", identity_number: "10101010005"} }
  let(:incorrect_account_type_data) { {country: "LV", identity_number: "020101-10000"} }

  describe ".authenticate" do
    it "makes a request to get session id" do
      response = described_class.authenticate(
        country: successful_data[:country],
        identity_number: successful_data[:identity_number]
      )
      expect(response).to be_a_kind_of(SmartId::Api::Response)
      expect(response.session_id).not_to be_nil 
    end
  end

  describe "#call" do
    context "with successful request" do
      let(:subject) do
        described_class.new(
          country: successful_data[:country],
          identity_number: successful_data[:identity_number]
        ) 
      end

      it "gets session ID for the authentication" do
        response = subject.call
        expect(response.session_id).not_to eq(nil)
      end
    end

    context "with incorrect account type request" do
      let(:subject) do
        described_class.new(
          country: incorrect_account_type_data[:country],
          identity_number: incorrect_account_type_data[:identity_number]
        ) 
      end

      it "raises error for code 471" do
        expect { subject.call }.to raise_error(SmartId::IncorrectAccountLevelError)
      end
    end
  end
end
