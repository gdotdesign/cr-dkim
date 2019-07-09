describe Dkim::QuotedPrintable do
  it "works" do
    encoded = "From:foo@eng.example.net|To:joe@example.com|Subject:demo=20run|Date:July=205,=202005=203:44:08=20PM=20-0700"
    decoded = "From:foo@eng.example.net|To:joe@example.com|Subject:demo run|Date:July 5, 2005 3:44:08 PM -0700"

    Dkim::QuotedPrintable.encode(decoded).should eq(encoded)
    Dkim::QuotedPrintable.decode(encoded).should eq(decoded)
  end
end
