module SmartId::Api
  module Authentication
    class ConfirmationPoller
      BASE_URI = "session/"

      def self.confirm(session_id)
        new(session_id).call
      end

      def initialize(session_id)
        @session_id = session_id
      end

      def call
        begin
          request = RestClient::Request.execute(
            method: :get, 
            url: api_url,
            headers: {  
              accept: :json,
              params: { timeoutMs: SmartId.poller_timeout_seconds * 1000} 
            },
            timeout: SmartId.poller_timeout_seconds + 1 # Add an extra second before request times out
          )
          
          response = ConfirmationResponse.new(JSON.parse(request.body))
          
          # repeat request if confirmation is still running
          if response.confirmation_running?
            call
          else
            response
          end
          
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

      def api_url
        SmartId.smart_id_base_url + BASE_URI + @session_id
      end
    end
  end
end
