RSpec.describe SmartId::Api::Authentication::Document do
  let(:mocked_auth_hash) { double(SmartId::Api::AuthenticationHash) }
  let(:successful_data) { "PNOEE-50001029996-MOCK-Q" }
  let(:missing_user_data) { "PNOLV-020101-10000-96R2-NQ" }
  let(:auth_hash) { SmartId::Utils::AuthenticationHash.new }

  describe ".authenticate" do
    it "makes a request to get session id" do
      response = described_class.authenticate(
        document_number: successful_data,
        authentication_hash: auth_hash
      )
      expect(response).to be_a_kind_of(SmartId::Api::Response)
      expect(response.session_id).not_to be_nil
    end
  end

  describe "#call" do
    context "with successful request" do
      let(:subject) do
        described_class.new(
          document_number: successful_data,
          authentication_hash: auth_hash
        )
      end

      it "gets session ID for the authentication" do
        response = subject.call
        expect(response.session_id).not_to eq(nil)
      end
    end

    context "with missing user request" do
      let(:subject) do
        described_class.new(
          document_number: missing_user_data,
          authentication_hash: auth_hash
        )
      end

      it "raises error for code 404" do
        expect { subject.call }.to raise_error(SmartId::UserNotFoundError)
      end
    end
  end
end
