import RFC_1035
import RFC_1123
import Testing

@testable import Domain_Standard

@Suite
struct `README Tests` {

    @Test
    func `Quick start`() throws {
        let domain = try Domain("example.com")

        #expect(domain.name == "example.com")
        #expect(domain.tld == "com")
        #expect(domain.sld == "example")

        let subdomain = try domain.addingSubdomain("www")
        #expect(subdomain.name == "www.example.com")
        #expect(subdomain.isSubdomain(of: domain))

        let parent = try subdomain.parent()
        #expect(parent == domain)
    }

    @Test
    func `RFC views`() throws {
        let domain = try Domain("example.com")
        #expect(domain.rfc1035 != nil)
        #expect(domain.rfc1123 == "example.com")

        let host = try Domain("123.example.com")
        #expect(host.rfc1035 == nil)

        let rfc1035 = try RFC_1035.Domain(domain)
        #expect(rfc1035 == "example.com")

        let rfc1123 = RFC_1123.Domain(host)
        #expect(rfc1123 == "123.example.com")
    }

    @Test
    func `IDNA`() throws {
        let domain = try Domain("xn--bcher-kva.example")
        #expect(domain.hasALabels)
        #expect(domain.isASCII)

        let ascii = try Domain(ascii: domain)
        #expect(ascii == domain)
    }

    @Test
    func `Errors`() {
        #expect(throws: Domain.Error.invalidFormat("invalid domain with spaces")) {
            try Domain("invalid domain with spaces")
        }
    }
}
