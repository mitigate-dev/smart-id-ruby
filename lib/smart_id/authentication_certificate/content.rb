module SmartId
  module AuthenticationCertificate
    class Content
      def initialize(raw_content)
        @raw_content = raw_content
      end

      def given_name
        structured_raw_content["GN"].gsub(",", " ")
      end

      def surname
        structured_raw_content["SN"].gsub(",", " ")
      end
      
      def country
        structured_raw_content["C"].gsub(",", " ")
      end

      def all_info
        structured_raw_content["CN"]
      end

      def organizational_unit
        structured_raw_content["OU"]
      end

      def identity_number
        structured_raw_content["serialNumber"]
      end

      private

      def structured_raw_content
        return @structured_raw_content if @structured_raw_content
        @structured_raw_content = @raw_content.split("/").each_with_object({}) do |c, result|
          if c.include?("=")
            key, val = c.split("=")
            result[key] = val
          end
        end
      end
    end
  end
end