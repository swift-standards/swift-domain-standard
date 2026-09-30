import Testing

@testable import Domain_Standard

@Suite
struct `Domain edge cases` {

    @Test
    func `a label starting with a digit is accepted through RFC 1123 only`() throws {
        let domain = try Domain("3com.example")

        #expect(domain.rfc1035 == nil)
        #expect(domain.name == "3com.example")
        #expect(domain.tld == "example")
    }

    @Test
    func `an RFC 1123 only domain has a parent and a root`() throws {
        let domain = try Domain("a.3com.example")

        #expect(try domain.parent()?.name == "3com.example")
        #expect(try domain.root()?.name == "3com.example")
    }

    @Test
    func `a subdomain is added below an RFC 1123 only domain`() throws {
        let domain = try Domain("3com.example")

        #expect(try domain.addingSubdomain("www").name == "www.3com.example")
    }

    @Test
    func `a subdomain check mixes RFC 1035 and RFC 1123 domains`() throws {
        let child = try Domain("www.3com.example")
        let parent = try Domain("3com.example")
        let unrelated = try Domain("other.example")

        #expect(child.isSubdomain(of: parent))
        #expect(!parent.isSubdomain(of: child))
        #expect(!child.isSubdomain(of: unrelated))
    }

    @Test
    func `a domain is not a subdomain of itself`() throws {
        let domain = try Domain("example.com")

        #expect(!domain.isSubdomain(of: domain))
    }

    @Test
    func `a single label domain has no parent`() throws {
        let domain = try Domain("localhost")

        #expect(try domain.parent() == nil)
    }

    @Test
    func `an invalid subdomain label is refused`() throws {
        let domain = try Domain("example.com")

        #expect(throws: Domain.Error.cannotCreateSubdomain) {
            try domain.addingSubdomain("-bad")
        }
    }

    @Test(arguments: ["", ".", "a..b", "exa mple.com", String(repeating: "a", count: 64) + ".com"])
    func `malformed text is refused`(_ text: String) {
        #expect(throws: Domain.Error.self) {
            try Domain(text)
        }
    }

    @Test
    func `empty labels are refused`() {
        #expect(throws: Domain.Error.self) {
            try Domain(labels: [String]())
        }
    }
}
