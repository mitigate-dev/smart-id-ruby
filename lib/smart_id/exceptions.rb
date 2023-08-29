module SmartId
  class Exception < ::Exception; end
  class InvalidParamsError < Exception; end
  class SSLCertificateNotVerified < Exception; end
  class InvalidResponseCertificate < Exception; end
  class InvalidResponseSignature < Exception; end
  class UserNotFoundError < Exception; end
  class OutdatedApiError < Exception; end
  class SystemUnderMaintenanceError < Exception; end
  class InvalidPermissionsError < Exception; end

  class ConnectionError < Exception;
    attr_reader :original_error
    def initialize(original_error)
      @original_error = original_error
    end
  end

  class IncorrectAccountLevelError < Exception
    def message
      "User exists, but has lower level account than required by request"
    end
  end
end
