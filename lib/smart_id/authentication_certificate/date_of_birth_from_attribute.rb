module SmartId
  module AuthenticationCertificate
    class DateOfBirthFromAttribute
      SUBJECT_DIRECTORY_ATTRIBUTES_NAME = 'subjectDirectoryAttributes'
      DATE_OF_BIRTH_ATTRIBUTE_NAME = 'id-pda-dateOfBirth'

      def initialize(cert)
        @cert = cert
      end

      def value
        extension = @cert.extensions.detect { |e| e.oid == SUBJECT_DIRECTORY_ATTRIBUTES_NAME }
        return unless extension

        value_der = OpenSSL::ASN1.decode(extension.to_der).value[1].value
        sequence = OpenSSL::ASN1.decode(value_der)
        date_of_birth_sequence = sequence.detect { |a| a.value.first&.value == DATE_OF_BIRTH_ATTRIBUTE_NAME }&.value
        return unless date_of_birth_sequence

        birth_time = date_of_birth_sequence[1]&.value&.[](0)&.value
        birth_time&.to_date
      end
    end
  end
end
