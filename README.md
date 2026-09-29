# swift-domain-standard

[![CI](https://github.com/swift-standards/swift-domain-standard/workflows/CI/badge.svg)](https://github.com/swift-standards/swift-domain-standard/actions/workflows/ci.yml)

A single `Domain` type over the RFC 1035 and RFC 1123 domain name models, with RFC 5890 IDNA checks.

## Overview

`Domain` validates its text as an RFC 1123 host name and additionally records the RFC 1035 form when the name also satisfies the stricter DNS syntax. Both views are values of their own standards packages:

- `rfc1123: RFC_1123.Domain` is always present
- `rfc1035: RFC_1035.Domain?` is present when every label starts with a letter

Apple Foundation bridging (`Codable`) lives in the `Domain Foundation Integration` product.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-domain-standard.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Domain Standard", package: "swift-domain-standard"),
        .product(name: "Domain Foundation Integration", package: "swift-domain-standard"),
    ]
)
```

## Quick start

```swift
import Domain_Standard

let domain = try Domain("example.com")
domain.name  // "example.com"
domain.tld   // Optional("com")
domain.sld   // Optional("example")

let subdomain = try domain.addingSubdomain("www")
subdomain.name                    // "www.example.com"
subdomain.isSubdomain(of: domain) // true

let parent = try subdomain.parent()
parent == domain                  // true
```

## RFC views

```swift
import RFC_1035
import RFC_1123

let domain = try Domain("example.com")
domain.rfc1035 != nil          // true
domain.rfc1123 == "example.com"

let host = try Domain("123.example.com")
host.rfc1035 == nil            // RFC 1035 labels start with a letter

let rfc1035 = try RFC_1035.Domain(domain)
let rfc1123 = RFC_1123.Domain(host)
```

## IDNA

```swift
let domain = try Domain("xn--bcher-kva.example")
domain.hasALabels  // true
domain.isASCII     // true

let ascii = try Domain(ascii: domain)
ascii == domain    // true
```

## Codable

```swift
import Domain_Foundation_Integration
import Foundation

let encoded = try JSONEncoder().encode(try Domain("example.com"))
String(decoding: encoded, as: UTF8.self)  // "\"example.com\""
let decoded = try JSONDecoder().decode(Domain.self, from: encoded)
```

## Errors

```swift
do throws(Domain.Error) {
    _ = try Domain("invalid domain with spaces")
} catch {
    // .invalidFormat("invalid domain with spaces")
}
```

`Domain.Error` cases: `invalidFormat`, `cannotCreateSubdomain`, `conversionFailure`, `idnaConversionFailure`.

## Requirements

- Swift 6.4
- macOS 27 / iOS 27 / tvOS 27 / watchOS 27

## License

Apache 2.0. See [LICENSE](LICENSE.md).
