module SmartId::Utils
  class CertificateValidator
    def self.validate!(hash_data, signature, certificate)
      obj = new(hash_data, signature, certificate)
      obj.validate_certificate!
      obj.validate_signature!
    end

    def initialize(hash_data, signature, certificate)
      @hash_data = hash_data
      @signature = signature
      begin
        @certificate = certificate.cert
      rescue Exception
        debugger
      end
    end

    def certificate_valid?
      ### TODO: Currently not working, because of error "unable to get local issuer certificate" - same error in bash with openssl
      # cert_store = OpenSSL::X509::Store.new
      # cert_chain.each {|c| cert_store.add_cert(c) }
      # cert_store.add_dir(File.dirname(__FILE__)+"/../../../trusted_certs/")
      # cert_store.purpose = OpenSSL::X509::PURPOSE_ANY
      # OpenSSL::X509::Store.new.verify(@certificate) &&
      @certificate.not_before.to_date <= Date.today &&
        @certificate.not_after.to_date >= Date.today
    end

    def validate_certificate!
      return unless @certificate
      unless certificate_valid?
        raise SmartId::InvalidResponseCertificate
      end
    end

    # def cert_chain
    #   [
    #     OpenSSL::X509::Certificate.new(
    #       File.read(File.dirname(__FILE__)+"/../../../trusted_certs/EID-SK_2016.pem.crt")
    #     ),
    #     OpenSSL::X509::Certificate.new(
    #       File.read(File.dirname(__FILE__)+"/../../../trusted_certs/NQ-SK_2016.pem.crt")
    #     )
    #   ]
    # end

    def validate_signature!
      return unless @certificate

      public_key = @certificate.public_key

      unless public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(@signature), @hash_data)
        raise SmartId::InvalidResponseSignature
      end
    end
  end
end
