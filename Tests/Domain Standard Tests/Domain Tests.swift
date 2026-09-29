import Testing

@testable import Domain_Standard

@Suite
struct `Domain Tests` {

    @Test
    func `a domain is created from its text form`() throws {
        let domain = try Domain("example.com")

        #expect(domain.name == "example.com")
        #expect(domain.tld == "com")
        #expect(domain.sld == "example")
    }

    @Test
    func `a domain is created from labels`() throws {
        let domain = try Domain(labels: ["mail", "example", "com"])

        #expect(domain.name == "mail.example.com")
    }

    @Test
    func `a malformed domain is refused`() {
        #expect(throws: Domain.Error.invalidFormat("invalid domain with spaces")) {
            try Domain("invalid domain with spaces")
        }
    }

    @Test
    func `a subdomain knows its parent`() throws {
        let parent = try Domain("example.com")
        let child = try Domain("mail.example.com")
        let unrelated = try Domain("other.com")

        #expect(child.isSubdomain(of: parent))
        #expect(!parent.isSubdomain(of: child))
        #expect(!child.isSubdomain(of: unrelated))
    }

    @Test
    func `a subdomain is added below a domain`() throws {
        let domain = try Domain("example.com")

        let subdomain = try domain.addingSubdomain("mail")

        #expect(subdomain.name == "mail.example.com")
        #expect(subdomain.isSubdomain(of: domain))
    }

    @Test
    func `several subdomain levels are added at once`() throws {
        let domain = try Domain("example.com")

        let subdomain = try domain.addingSubdomain("api", "v1")

        #expect(subdomain.name == "api.v1.example.com")
    }

    @Test
    func `the parent of a subdomain is the domain above it`() throws {
        let domain = try Domain("mail.example.com")

        let parent = try domain.parent()

        #expect(parent?.name == "example.com")
    }

    @Test
    func `the root of a deep subdomain is its registrable domain`() throws {
        let domain = try Domain("api.v1.example.com")

        let root = try domain.root()

        #expect(root?.name == "example.com")
    }

    @Test
    func `a domain describes itself by its name`() throws {
        let domain = try Domain("example.com")

        #expect(domain.description == "example.com")
        #expect("\(domain)" == "example.com")
    }
}
