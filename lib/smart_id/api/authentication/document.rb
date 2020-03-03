require "smart_id/api/authentication/base"

module SmartId::Api
  module Authentication
    class Document < Base
      BASE_URI = "authentication/document"

      def initialize(**opts)
        @document_number = opts[:document_number]

        super(**opts)
      end

      private

      def api_url
        SmartId.smart_id_base_url + "#{BASE_URI}/#{@document_number}"
      end
    end
  end
end
