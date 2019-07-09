module Dkim
  module QuotedPrintable
    extend self

    DkimUnafeChar = /[^\x21-\x3A\x3C\x3E-\x7E]/

    def encode(string)
      string.gsub(DkimUnafeChar) do |char|
        "=" + char[0].ord.to_s(16)
      end
    end

    def decode(string)
      string.gsub(/=([0-9A-F]{2})/) do |string, match|
        String.new(Bytes[match[1].to_u8(16)])
      end
    end
  end
end
