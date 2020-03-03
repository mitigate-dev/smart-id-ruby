module SmartId
  module Utils
    class VerificationCodeCalculator
      ##
      # The Verification Code (VC) is computed as:
      #
      # integer(SHA256(hash)[−2:−1]) mod 10000
      #
      # where we take SHA256 result, extract 2 rightmost bytes from it,
      # interpret them as a big-endian unsigned short and take the last 4 digits in decimal for display.
      #
      # SHA256 is always used here, no matter what was the algorithm used to calculate hash.

      def self.calculate(data)
        digest = AuthenticationHash.new(data).calculate_digest
        rightmost_bytes = digest[-2..-1]
        int = rightmost_bytes.unpack('n*')[0]
        paddable_string = (int % 10000).to_s.chars.last(4).join
        pad = 4 - paddable_string.length
        
        "0" * pad + paddable_string
      end
    end
  end
end