require 'logger'
require 'date'
module SmartId::Api
  class Request
    DEMO_BASE_URL = "https://sid.demo.sk.ee/smart-id-rp/v1/"
    PRODUCTION_BASE_URL = "https://rp-api.smart-id.com/v1/"

    DEMO_SSL_KEY = "QLZIaH7Qx9Rjq3gyznQuNsvwMQb7maC5L4SLu/z5qNU="
    PROD_KEY_EXPIRY = Date.new(2020,11,5)
    PRODUCTION_SSL_KEY = "l2uvq6ftLN4LZ+8Un+71J2vH1BT9wTbtrE5+Fj3Vc5g="

    def initialize(method, uri, params)
      @method = method
      @url = self.class.const_get("#{SmartId.environment}_BASE_URL") + uri
      @params = params
      @logger = Logger.new(STDOUT)
    end

    def self.execute(method:, uri:, params:)
      begin
        api_request = new(method, uri, params)
        api_request.execute
      rescue RestClient::RequestFailed => e
        case e.http_code
        when 471
          raise SmartId::IncorrectAccountLevelError
        else
          raise SmartId::ConnectionError
        end
      rescue RestClient::SSLCertificateNotVerified
        raise SmartId::SSLCertificateNotVerified
      end
    end

    def maybe_warn_of_ssl_key_expiry
      if (PROD_KEY_EXPIRY - Date.today).to_i < 60
        @logger.warn("[Smart-id-Ruby] SSL KEY for security checks will soon expire, please update to newer version of this gem")
      end
    end

    def execute
      maybe_warn_of_ssl_key_expiry

      if @method.to_sym == :post
        attrs = post_request_attrs
      else
        attrs = get_request_attrs
      end 

      request = RestClient::Request.execute(**attrs)
    end

    private
    
    def default_attrs
      {
        method: @method,
        url: @url,
        headers: { content_type: :json, accept: :json },
        timeout: SmartId.poller_timeout_seconds + 1,
        ssl_verify_callback: lambda do |_, cert_store|
          provided_pub_key = cert_store.chain[0].public_key
          saved_key = self.class.const_get("#{SmartId.environment}_SSL_KEY")
          Digest::SHA256.digest(provided_pub_key.to_der) == Base64.decode64(saved_key)
        end
      }
    end

    def get_request_attrs
      default_attrs.merge(headers: {
        **default_attrs[:headers],
        params: @params 
      })
    end

    def post_request_attrs
      default_attrs.merge(payload: JSON.generate(@params))
    end
  end
end