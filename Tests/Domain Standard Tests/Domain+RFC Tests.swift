import RFC_1035
import RFC_1123
import Testing

@testable import Domain_Standard

@Suite
struct `Domain+RFC Tests` {

    @Test
    func `a domain is built from an RFC 1035 domain`() throws {
        let rfc1035 = try RFC_1035.Domain("example.com")

        let domain = try Domain(rfc1035: rfc1035)

        #expect(domain.name == "example.com")
        #expect(domain.rfc1035 == rfc1035)
        #expect(domain.rfc1123 == "example.com")
    }

    @Test
    func `a domain is built from an RFC 1123 domain`() throws {
        let rfc1123 = try RFC_1123.Domain("example.com")

        let domain = Domain(rfc1123: rfc1123)

        #expect(domain.name == "example.com")
        #expect(domain.rfc1123 == rfc1123)
        #expect(domain.rfc1035?.name == "example.com")
    }

    @Test
    func `a host name with a leading digit is RFC 1123 only`() throws {
        let domain = try Domain("123.example.com")

        #expect(domain.rfc1035 == nil)
        #expect(domain.rfc1123 == "123.example.com")
    }

    @Test
    func `an RFC 1035 domain is recovered from a domain`() throws {
        let domain = try Domain("example.com")

        let rfc1035 = try RFC_1035.Domain(domain)

        #expect(rfc1035 == "example.com")
    }

    @Test
    func `an RFC 1035 domain refuses a host name with a leading digit`() throws {
        let domain = try Domain("123.example.com")

        #expect(throws: RFC_1035.Domain.Error.self) {
            try RFC_1035.Domain(domain)
        }
    }

    @Test
    func `an RFC 1123 domain is recovered from any domain`() throws {
        let domain = try Domain("123.example.com")

        let rfc1123 = RFC_1123.Domain(domain)

        #expect(rfc1123 == "123.example.com")
    }

    @Test
    func `an empty domain is refused`() {
        #expect(throws: Domain.Error.invalidFormat("")) {
            try Domain("")
        }
    }

    @Test
    func `a domain with too many labels is refused`() {
        let name = Array(repeating: "a", count: 128).joined(separator: ".")

        #expect(throws: Domain.Error.invalidFormat(name)) {
            try Domain(name)
        }
    }

    @Test
    func `a domain longer than 255 bytes is refused`() {
        let name = Array(repeating: String(repeating: "a", count: 63), count: 5).joined(separator: ".")

        #expect(throws: Domain.Error.invalidFormat(name)) {
            try Domain(name)
        }
    }

    @Test
    func `a label starting with a hyphen is refused`() {
        #expect(throws: Domain.Error.invalidFormat("-example.com")) {
            try Domain("-example.com")
        }
    }

    @Test
    func `a label ending with a hyphen is refused`() {
        #expect(throws: Domain.Error.invalidFormat("example-.com")) {
            try Domain("example-.com")
        }
    }

    @Test
    func `a label with a special character is refused`() {
        #expect(throws: Domain.Error.invalidFormat("host@name.com")) {
            try Domain("host@name.com")
        }
    }

    @Test
    func `a top-level domain starting with a digit is refused`() {
        #expect(throws: Domain.Error.invalidFormat("example.123com")) {
            try Domain("example.123com")
        }
    }

    @Test
    func `a top-level domain ending with a digit is accepted`() throws {
        let domain = try Domain("example.com123")

        #expect(domain.name == "example.com123")
        #expect(domain.tld == "com123")
    }

    @Test
    func `labels mixing letters and digits are accepted`() throws {
        let domain = try Domain("host123.example456.com")

        #expect(domain.name == "host123.example456.com")
        #expect(domain.rfc1035?.name == "host123.example456.com")
    }

    @Test
    func `an RFC 1035 domain that RFC 1123 refuses fails to convert`() throws {
        let rfc1035 = try RFC_1035.Domain("example.com.")

        #expect(throws: Domain.Error.conversionFailure("RFC 1035", to: "RFC 1123")) {
            try Domain(rfc1035: rfc1035)
        }
    }

    @Test
    func `a subdomain is added below a host name that is RFC 1123 only`() throws {
        let domain = try Domain("123.example.com")

        let subdomain = try domain.addingSubdomain("mail")

        #expect(subdomain.name == "mail.123.example.com")
        #expect(subdomain.rfc1035 == nil)
        #expect(subdomain.isSubdomain(of: domain))
    }

    @Test
    func `the parent of a host name that is RFC 1123 only regains its RFC 1035 form`() throws {
        let domain = try Domain("123.example.com")

        let parent = try domain.parent()

        #expect(parent?.name == "example.com")
        #expect(parent?.rfc1035?.name == "example.com")
    }

    @Test
    func `the root of a host name that is RFC 1123 only is its registrable domain`() throws {
        let domain = try Domain("api.123.example.com")

        let root = try domain.root()

        #expect(root?.name == "example.com")
    }

    @Test
    func `a single-label domain has neither parent nor root`() throws {
        let domain = try Domain("localhost")

        #expect(try domain.parent() == nil)
        #expect(try domain.root() == nil)
    }

    @Test
    func `the root of a registrable domain is itself`() throws {
        let domain = try Domain("example.com")

        #expect(try domain.root() == domain)
    }

    @Test
    func `a subdomain with an invalid label is refused`() throws {
        let domain = try Domain("example.com")

        #expect(throws: Domain.Error.cannotCreateSubdomain) {
            try domain.addingSubdomain("-mail")
        }
    }

    @Test
    func `a subdomain that makes the domain too long is refused`() throws {
        let domain = try Domain(labels: Array(repeating: String(repeating: "a", count: 63), count: 4))

        #expect(throws: Domain.Error.cannotCreateSubdomain) {
            try domain.addingSubdomain("mail")
        }
    }
}
