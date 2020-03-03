require "smart_id/version"
require "smart_id/utils/authentication_hash"
require "smart_id/utils/verification_code_calculator"
require "smart_id/api/response"
require "smart_id/api/confirmation_response"
require "smart_id/api/authentication/identity_number"
require "smart_id/api/authentication/document"
require "smart_id/api/authentication/confirmation_poller"

module SmartId
    @@relying_party_uuid = nil
    @@relying_party_name = nil
    @@default_certificate_level = "QUALIFIED" 
    @@host_url = nil
    @@smart_id_base_url = "https://sid.demo.sk.ee/smart-id-rp/v1/"
    @@poller_timeout_seconds = 10

  def self.configure(&block)
    yield(self)
  end

  def self.relying_party_uuid=(value)
    @@relying_party_uuid = value
  end

  def self.relying_party_uuid
    @@relying_party_uuid
  end

  def self.relying_party_name=(value)
    @@relying_party_name = value
  end

  def self.relying_party_name
    @@relying_party_name
  end

  def self.default_certificate_level=(value)
    @@default_certificate_level = value
  end

  def self.default_certificate_level
    @@default_certificate_level
  end

  def self.smart_id_base_url=(value)
    @@smart_id_base_url = value
  end

  def self.smart_id_base_url
    @@smart_id_base_url
  end

  def self.poller_timeout_seconds=(value)
    @@poller_timeout_seconds = value
  end

  def self.poller_timeout_seconds
    @@poller_timeout_seconds
  end
end
