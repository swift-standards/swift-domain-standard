// swift-tools-version:6.2

import PackageDescription

extension String {
    static let domain: Self = "Domain Standard"
}

extension Target.Dependency {
    static var domain: Self { .target(name: .domain) }
}

extension Target.Dependency {
    static var rfc1035: Self { .product(name: "RFC 1035", package: "swift-rfc-1035") }
    static var rfc1123: Self { .product(name: "RFC 1123", package: "swift-rfc-1123") }
    static var rfc5321: Self { .product(name: "RFC 5321", package: "swift-rfc-5321") }
    static var rfc5890: Self { .product(name: "RFC 5890", package: "swift-rfc-5890") }
}

let package = Package(
    name: "swift-domain-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "Domain Standard", targets: ["Domain Standard"])
    ],
    dependencies: [
        .package(path: "../swift-rfc-1035"),
        .package(path: "../swift-rfc-1123"),
        .package(path: "../swift-rfc-5321"),
        .package(path: "../swift-rfc-5890")
    ],
    targets: [
        .target(
            name: "Domain Standard",
            dependencies: [
                .rfc1035,
                .rfc1123,
                .rfc5321,
                .rfc5890
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
