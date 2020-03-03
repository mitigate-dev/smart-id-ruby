require "rest-client"
require "smart_id/exceptions"
require "smart_id/utils/authentication_hash"
require "json"
require 'byebug'

module SmartId::Api
  module Authentication
    class Base
      attr_reader :authentication_hash

      def self.authenticate(**opts)
        new(**opts).call
      end

      def initialize(**opts)
        @authentication_hash = SmartId::Utils::AuthenticationHash.new(opts[:hashable_data])
        @display_text = opts[:display_text]
        @nonce = opts[:nonce]
        @certificate_level = opts[:certificate_level]
      end


      def call
        begin
          request = RestClient::Request.execute(
            method: :post, 
            url: api_url,
            payload: JSON.generate(request_params),
            headers: { content_type: :json, accept: :json }
          )
          SmartId::Api::Response.new(JSON.parse(request.body), @authentication_hash)
          
        rescue RestClient::RequestFailed => e
          case e.http_code
          when 471
            raise SmartId::IncorrectAccountLevelError
          else
            raise SmartId::ConnectionError
          end
        end
      end

      private

      def request_params
        params = {
          relyingPartyUUID: SmartId.relying_party_uuid,
          relyingPartyName: SmartId.relying_party_name,
          certificateLevel: @certificate_level || SmartId.default_certificate_level,
          hash: @authentication_hash.calculate_base64_digest,
          hashType: "SHA256"
        }

        if @display_text
          params.merge!(displayText: @display_text)
        end

        if @nonce
          params.merge!(nonce: @nonce)
        end

        params
      end

      def api_url
        raise NotImplementedError
      end
    end
  end
end