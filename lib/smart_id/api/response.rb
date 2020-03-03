module SmartId::Api
  class Response
    attr_reader :session_id

    def initialize(response_body, authentication_hash)
      @body = response_body
      @session_id = response_body["sessionID"]
      @authentication_hash = authentication_hash
    end

    def verification_code
      @verification_code ||= SmartId::VerificationCodeCalculator.calculate(@authentication_hash.hashable_data)
    end
  end
end
