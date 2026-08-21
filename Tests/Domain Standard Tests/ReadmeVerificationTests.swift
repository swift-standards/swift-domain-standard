import Foundation
import RFC_1035
import RFC_1123
import Testing

@testable import Domain_Standard

@Suite("README Code Examples Validation", .serialized)
struct ReadmeVerificationTests {

    @Test
    func `Quick Start - Basic Domain Creation (README lines 43-53)`() throws {

        let domain = try Domain("example.com")
        #expect(domain.name == "example.com")

        #expect(domain.tld == "com")
        #expect(domain.sld == "example")
    }

    @Test
    func `Quick Start - Working with Subdomains (README lines 57-68)`() throws {
        let domain = try Domain("example.com")

        let subdomain = try domain.addingSubdomain("www")
        #expect(subdomain.name == "www.example.com")

        let isSubdomain = subdomain.isSubdomain(of: domain)
        #expect(isSubdomain == true)

        let parent = try subdomain.parent()
        #expect(parent?.name == "example.com")
    }

    @Test
    func `Quick Start - Multi-RFC Format Support (README lines 72-88)`() throws {

        let domain = try Domain("example.com")

        #expect(domain.isStandardDomain == true)

        if let rfc1035 = domain.rfc1035 {

            #expect(rfc1035.name == "example.com")
        }

        #expect(domain.rfc1123.name == "example.com")

        #expect(domain.rfc1123.name == "example.com")
    }

    @Test
    func `Initializing Domains (README lines 94-104)`() throws {

        let domain1 = try Domain("example.com")
        #expect(domain1.name == "example.com")

        let domain2 = try Domain(labels: ["www", "example", "com"])
        #expect(domain2.name == "www.example.com")

        let rfc1035Domain = try RFC_1035.Domain("example.com")
        let domain3 = try Domain(rfc1035: rfc1035Domain)
        #expect(domain3.name == "example.com")
    }

    @Test
    func `Domain Operations (README lines 108-125)`() throws {
        let domain = try Domain("example.com")

        let deepSubdomain = try domain.addingSubdomain("api", "v1")

        #expect(deepSubdomain.name == "api.v1.example.com")

        var current: Domain? = deepSubdomain
        var hierarchy: [String] = []
        while let dom = current {
            hierarchy.append(dom.name)
            current = try? dom.parent()
        }

        #expect(hierarchy.contains("api.v1.example.com"))
        #expect(hierarchy.contains("v1.example.com"))
        #expect(hierarchy.contains("example.com"))
    }

    @Test
    func `Subdomain Checking (README lines 129-139)`() throws {
        let root = try Domain("example.com")
        let sub1 = try Domain("www.example.com")
        let sub2 = try Domain("api.example.com")
        let other = try Domain("other.com")

        #expect(sub1.isSubdomain(of: root) == true)
        #expect(sub2.isSubdomain(of: root) == true)
        #expect(other.isSubdomain(of: root) == false)
        #expect(root.isSubdomain(of: sub1) == false)
    }

    @Test
    func `Codable Support (README lines 143-155)`() throws {
        struct Config: Codable {
            let domain: Domain
        }

        let config = Config(domain: try Domain("example.com"))
        let jsonData = try JSONEncoder().encode(config)
        #expect(!jsonData.isEmpty)

        let decoded = try JSONDecoder().decode(Config.self, from: jsonData)
        #expect(decoded.domain.name == "example.com")
    }

    @Test
    func `RawRepresentable (README lines 159-168)`() throws {
        let domain = try Domain("example.com")

        let rawValue = domain.rawValue
        #expect(rawValue == "example.com")

        let reconstructed = Domain(rawValue: "example.com")
        #expect(reconstructed?.name == "example.com")
    }

    @Test
    func `Error Handling (README lines 207-219)`() throws {

        do {
            let _ = try Domain("invalid domain with spaces")
            Issue.record("Should have thrown an error for invalid domain")
        } catch {

            #expect(true, "Correctly threw error for invalid domain")
        }
    }
}
