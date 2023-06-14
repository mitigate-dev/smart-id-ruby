module SmartId
  module AuthenticationCertificate
    class Certificate
      def initialize(base64_cert)
        @base64_cert = base64_cert
      end

      def content
        @content ||= SmartId::AuthenticationCertificate::Content.new(cert.subject.to_s)
      end

      def cert
        @cert ||= OpenSSL::X509::Certificate.new(Base64.decode64(@base64_cert))
      end

      def date_of_birth_from_attribute
        return unless @base64_cert

        @date_of_birth_from_attribute ||= SmartId::AuthenticationCertificate::DateOfBirthFromAttribute.new(cert).value
      end
    end
  end
end
