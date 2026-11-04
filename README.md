# swift-domain-standard

Use this package when you need a domain or host name that is valid under both DNS syntax (RFC 1035) and host name syntax (RFC 1123), and you don't want to pick one standard. Start from `Domain`. If you need exactly one standard's rules, use `RFC_1035.Domain` from swift-rfc-1035 or `RFC_1123.Domain` from swift-rfc-1123. For `Codable`, add the `Domain Foundation Integration` product.

## Laws

- Text is validated as an RFC 1123 host name. `Domain.rfc1123` is always set. `Domain.rfc1035` is set only when the name also meets RFC 1035, so a name with a label that starts with a digit, such as `123.example.com`, is accepted with `rfc1035` nil.
- `Domain.rfc1035` is recomputed for every derived domain. The parent of `123.example.com` is `example.com` and has its RFC 1035 form again.
- An RFC 1035 name that RFC 1123 refuses, such as the absolute form `example.com.`, can't become a `Domain`.
- `Domain.isSubdomain(of:)` is strict: a domain is not a subdomain of itself. It compares the RFC 1035 forms when both domains have one, and the RFC 1123 forms otherwise.
- `Domain.parent()` drops the leftmost label. `Domain.root()` keeps the last two labels, so the root of `example.com` is itself. A single-label name such as `localhost` has neither, and both return nil rather than throwing.
- `Domain.addingSubdomain(_:)` reports every refusal, whether from a bad label or a name that grows too long, as the same `Domain.Error.cannotCreateSubdomain`.
- A `Domain` only ever holds an ASCII host name. `Domain.init(ascii:)` returns an ASCII domain unchanged, and `Domain.init(unicode:)` throws, because the Unicode form of an A-label is not a valid host name.
- With `Domain Foundation Integration`, a domain encodes as its `name` string and decodes from one. Text that isn't a valid domain fails to decode with a data-corrupted `DecodingError`.
