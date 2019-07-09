module Dkim
  class SignedMail
    delegate signable_headers, signing_algorithm, domain, identity,
      selector, header_canonicalization, body_canonicalization, private_key,
      time,
      to: @options

    getter headers : Hash(String, String)
    getter body : String

    def initialize(@original_message : String, @options : Options)
      message =
        @original_message
          .gsub(/\r?\n/, "\r\n")

      headers, body =
        message
          .split(/\r?\n\r?\n/, 2)

      @headers =
        header_canonicalizer
          .headers(Header.parse(headers))

      @body =
        body_canonicalizer
          .body(body)
    end

    def dkim_header
      dkim_header = {} of String => String

      # Add basic DKIM info
      dkim_header["v"] = "1"
      dkim_header["a"] = signing_algorithm
      dkim_header["c"] = "#{header_canonicalization}/#{body_canonicalization}"
      dkim_header["d"] = domain

      identity.try { |value| dkim_header["i"] = value }

      dkim_header["q"] = "dns/txt"
      dkim_header["s"] = selector
      dkim_header["t"] = (time || Time.now).to_unix_ms.to_s

      # Add body hash and blank signature
      dkim_header["bh"] = body_hash
      dkim_header["h"] = headers.keys.join(":").downcase
      dkim_header["b"] = ""

      # Calculate signature based on intermediate signature header
      joined_headers =
        headers.map { |key, value| "#{key}:#{value}" }.join("\r\n") + "\r\n" +
          "DKIM-Signature: " + construct(dkim_header)

      dkim_header["b"] = Base64.encode(OpenSSL::RSA.new(private_key).sign(get_digest_algorithm, joined_headers))

      construct(dkim_header)
    end

    def construct(header)
      header.map do |key, value|
        value = case key
                when "i", "z"
                  QuotedPrintable.encode(value)
                when "b", "bh"
                  value.gsub("\n", "")
                else
                  value
                end

        "#{key}=#{value}"
      end.join("; ")
    end

    def header_canonicalizer
      Canonicalizer.from(header_canonicalization)
    end

    def body_canonicalizer
      Canonicalizer.from(body_canonicalization)
    end

    def body_hash
      digest = get_digest_algorithm
      digest.update(body)
      digest.base64digest.rstrip
    end

    def get_digest_algorithm
      case signing_algorithm
      when "rsa-sha1"
        OpenSSL::Digest.new("SHA1")
      when "rsa-sha256"
        OpenSSL::Digest.new("SHA256")
      else
        raise "Unknown digest algorithm: '#{signing_algorithm}'"
      end
    end
  end
end
