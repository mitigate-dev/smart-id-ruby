RSpec.describe SmartId::Api::Authentication::ConfirmationPoller do
  describe "#call" do
    context "with good confirmation" do
      let(:user_data) { "PNOEE-10101010005-Z1B2-Q" }
      let(:auth_hash) { SmartId::Utils::AuthenticationHash.new }
      let(:authentication_response) do
        SmartId::Api::Authentication::Document.authenticate(
           document_number: user_data,
          authentication_hash: auth_hash
        )
      end
      
      subject { described_class.new(authentication_response.session_id, auth_hash) }

      it "gets session confirmation from the user" do
        response = subject.call

        expect(response).to be_a_kind_of(SmartId::Api::ConfirmationResponse)
        expect(response.confirmation_running?).to be_falsey
        expect(response.document_number).to eq(user_data)
        expect(response.signature).not_to be_nil
        expect(response.certificate).not_to be_nil
        expect(response.certificate_level).not_to be_nil
        expect(response.signature_algorithm).not_to be_nil
        
      end
    end
  end
end