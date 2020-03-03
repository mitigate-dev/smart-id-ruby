RSpec.describe SmartId::Api::Authentication::Document do
  let(:successful_data) { "PNOEE-10101010005-Z1B2-Q" }
  let(:incorrect_account_type_data) { "PNOLV-020101-10000-96R2-NQ" }

  describe ".authenticate" do
    it "makes a request to get session id" do
      response = described_class.authenticate(document_number: successful_data)
      expect(response).to be_a_kind_of(SmartId::Api::Response)
      expect(response.session_id).not_to be_nil 
    end
  end

  describe "#call" do
    context "with successful request" do
      let(:subject) do
        described_class.new(document_number: successful_data) 
      end

      it "gets session ID for the authentication" do
        response = subject.call
        expect(response.session_id).not_to eq(nil)
      end
    end

    context "with incorrect account type request" do
      let(:subject) do
        described_class.new(document_number: incorrect_account_type_data) 
      end

      it "raises error for code 471" do
        expect { subject.call }.to raise_error(SmartId::IncorrectAccountLevelError)
      end
    end
  end
end
