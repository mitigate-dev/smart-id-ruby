module SmartId::Api
  class ConfirmationResponse
    RUNNING_STATE = "RUNNING"
    COMPLETED_STATE = "COMPLETE"

    attr_reader :body
    
    def initialize(response_body)
      @body = response_body
    end

    def state
      @body["state"]
    end

    def confirmation_complete?
      state == COMPLETED_STATE
    end

    def confirmation_running?
      state == RUNNING_STATE
    end

    def end_result
      @body.dig("result", "endResult")
    end

    def document_number
      @body.dig("result", "documentNumber")
    end

    def certificate_level
      @body.dig("cert", "certificateLevel")
    end

    def certificate
      @body.dig("cert", "value")
    end

    def signature_algorithm
      @body.dig("signature", "algorithm")
    end

    def signature
      @body.dig("signature", "value")
    end

    def ignored_properties
      @body["ignoredProperties"]
    end
  end
end
