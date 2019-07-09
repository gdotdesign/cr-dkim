module Dkim
  struct Options
    # This corresponds to the t= tag in the dkim header.
    # The default (nil) is to use the current time at signing.
    property time : Time | Nil

    # The signing algorithm for dkim. Valid values are 'rsa-sha1' and 'rsa-sha256' (default).
    # This corresponds to the a= tag in the dkim header.
    property signing_algorithm : String

    # Configures which headers should be signed.
    property signable_headers : Array(String)

    # The domain used for signing.
    property domain : String

    # The identity used for signing.
    # This corresponds to the i= tag in the dkim header.
    property identity : String | Nil

    # Selector used for signing.
    # This corresponds to the s= tag in the dkim header.
    property selector : String

    # Header normalizer algorithm.
    # Valid values are 'simple' and 'relaxed' (default)
    # This corresponds to the first half of the c= tag in the dkim header.
    property header_canonicalization : String

    # Body normalizer algorithm.
    # Valid values are 'simple' and 'relaxed' (default)
    # This corresponds to the second half of the c= tag in the dkim header.
    property body_canonicalization : String

    # RSA private key for signing.
    property private_key : String

    def initialize(@time,
                   @signing_algorithm,
                   @signable_headers,
                   @domain,
                   @identity,
                   @selector,
                   @header_canonicalization,
                   @body_canonicalization,
                   @private_key)
    end
  end
end
