import Testing

@testable import Domain_Standard

@Suite
struct `Domain+IDNA Tests` {

    @Test
    func `an ASCII domain converts to itself`() throws {
        let domain = try Domain("example.com")

        let ascii = try Domain(ascii: domain)

        #expect(ascii == domain)
        #expect(ascii.isASCII)
        #expect(!ascii.isInternationalized)
    }

    @Test
    func `a domain with an A-label reports it`() throws {
        let domain = try Domain("xn--bcher-kva.example")

        #expect(domain.hasALabels)
        #expect(domain.isASCII)
        #expect(!domain.isInternationalized)
    }

    @Test
    func `a plain domain has no A-labels`() throws {
        let domain = try Domain("example.com")

        #expect(!domain.hasALabels)
    }

    @Test
    func `a Unicode form is refused because domains are ASCII host names`() throws {
        let domain = try Domain("xn--bcher-kva.example")

        #expect(throws: Domain.Error.self) {
            try Domain(unicode: domain)
        }
    }
}
