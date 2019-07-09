require "./spec_helper"

RSA = "-----BEGIN RSA PRIVATE KEY-----
MIICXwIBAAKBgQDwIRP/UC3SBsEmGqZ9ZJW3/DkMoGeLnQg1fWn7/zYtIxN2SnFC
jxOCKG9v3b4jYfcTNh5ijSsq631uBItLa7od+v/RtdC2UzJ1lWT947qR+Rcac2gb
to/NMqJ0fzfVjH4OuKhitdY9tf6mcwGjaNBcWToIMmPSPDdQPNUYckcQ2QIDAQAB
AoGBALmn+XwWk7akvkUlqb+dOxyLB9i5VBVfje89Teolwc9YJT36BGN/l4e0l6QX
/1//6DWUTB3KI6wFcm7TWJcxbS0tcKZX7FsJvUz1SbQnkS54DJck1EZO/BLa5ckJ
gAYIaqlA9C0ZwM6i58lLlPadX/rtHb7pWzeNcZHjKrjM461ZAkEA+itss2nRlmyO
n1/5yDyCluST4dQfO8kAB3toSEVc7DeFeDhnC1mZdjASZNvdHS4gbLIA1hUGEF9m
3hKsGUMMPwJBAPW5v/U+AWTADFCS22t72NUurgzeAbzb1HWMqO4y4+9Hpjk5wvL/
eVYizyuce3/fGke7aRYw/ADKygMJdW8H/OcCQQDz5OQb4j2QDpPZc0Nc4QlbvMsj
7p7otWRO5xRa6SzXqqV3+F0VpqvDmshEBkoCydaYwc2o6WQ5EBmExeV8124XAkEA
qZzGsIxVP+sEVRWZmW6KNFSdVUpk3qzK0Tz/WjQMe5z0UunY9Ax9/4PVhp/j61bf
eAYXunajbBSOLlx4D+TunwJBANkPI5S9iylsbLs6NkaMHV6k5ioHBBmgCak95JGX
GMot/L2x0IYyMLAz6oLWh2hm7zwtb0CgOrPo1ke44hFYnfc=
-----END RSA PRIVATE KEY-----"

MESSAGE = %{From: Joe SixPack <IIVyTowbcT@www.brandonchecketts.com>
To: Suzie Q <suzie@shopping.example.net>
Subject: Is dinner ready?
Date: Fri, 11 Jul 2003 21:00:37 -0700 (PDT)
Message-ID: <20030712040037.46341.5F8J@football.example.com>

Hi.

We lost the game. Are you hungry yet?

Joe.}

def parse_header(value)
  value.split(";").map(&.strip).reduce({} of String => String) do |memo, item|
    key, value = item.split("=", 2)
    memo[key] = value
    memo
  end
end

describe Dkim do
  it "works" do
    header_string = Dkim.header(MESSAGE, Dkim::Options.new(
      time: Time.unix_ms(1234567890),
      signing_algorithm: "rsa-sha256",
      signable_headers: Dkim::DefaultHeaders,
      domain: "example.com",
      identity: "joe@football.example.com",
      selector: "brisbane",
      header_canonicalization: "simple",
      body_canonicalization: "simple",
      private_key: RSA,
    ))

    header = parse_header(header_string)

    header["bh"].should eq("2jUSOH9NhtVGCQWNr9BrIAPreKQjO6Sn7XIkfJVOzv8=")
    header["b"].should eq("L3/HjX3kRrV7V2XiNE4dxHOLnRglFwBfy0js8PlhDqXQ7DFiRS1rco/1b+cencDXz6RHFui+n/O1RFGGNn+TO5DjNq57lqdlge60rivF7U6VenQL8/QYsWIx17cQZb0bsFHIyfTaOls1ujX18C6ucO3DtF4I645FpY/UeU+xatg=")
  end
end
