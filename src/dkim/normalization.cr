module Dkim
  module Canonicalizer
    extend self

    def from(from)
      case from
      when "simple"
        SimpleCanonicalizer
      when "relaxed"
        RelaxedCanonicalizer
      else
        raise "Unknown canonicalization: #{from}"
      end
    end
  end

  module SimpleCanonicalizer
    include Canonicalizer

    extend self

    def headers(value : Hash(String, String))
      value
    end

    def body(value : String) : String
      body =
        value.gsub(/(\r?\n)*\z/, "")

      "#{body}\r\n"
    end
  end

  module RelaxedCanonicalizer
    include Canonicalizer

    extend self

    def headers(value : Hash(String, String))
      value
        .transform_keys { |key| key.downcase.gsub(/[ \t]*\z/, "") }
        .transform_values do |value|
          value
            .gsub(/\r?\n[ \t]+/, " ") # Unfold all header field continuation lines as described in [RFC2822]
            .gsub(/[ \t]+/, " ")      # Convert all sequences of one or more WSP characters to a single SP character.
            .gsub(/[ \t]*\z/, "")     # Delete all WSP characters at the end of each unfolded header field value.
            .gsub(/\A[ \t]*/, "")     # Delete any WSP characters remaining after the colon separating the header field name from the header field value.
        end
    end

    def body(value : String)
      return "" if value.empty?

      body =
        value
          .gsub(/[ \t]+/, " ")    # Reduces all sequences of WSP within a line to a single SP character.
          .gsub(/ \r\n/, "\r\n")  # Ignores all whitespace at the end of lines.  Implementations MUST NOT remove the CRLF at the end of the line.
          .gsub(/[ \r\n]*\z/, "") # Ignores all empty lines at the end of the message body.

      "#{body}\r\n"
    end
  end
end
