module Dkim
  module Header
    extend self

    def parse(header) : Hash(String, String)
      header
        .split(/\r?\n(?!([ \s\t]))/)
        .reduce({} of String => String) do |memo, header|
          key, value = header.split(':', 2)

          memo[key] = value
          memo
        end
    end
  end
end
