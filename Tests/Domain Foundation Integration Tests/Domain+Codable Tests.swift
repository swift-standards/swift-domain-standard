import Domain_Foundation_Integration
import Domain_Standard
import Foundation
import Testing

@Suite
struct `Domain+Codable Tests` {

    @Test
    func `a domain codes as its text form`() throws {
        let domain = try Domain("mail.example.com")

        let encoded = try JSONEncoder().encode(domain)

        #expect(String(decoding: encoded, as: UTF8.self) == #""mail.example.com""#)
        #expect(try JSONDecoder().decode(Domain.self, from: encoded) == domain)
    }

    @Test
    func `a domain codes as a field of a record`() throws {
        struct Config: Codable, Equatable {
            let domain: Domain
        }
        let config = Config(domain: try Domain("example.com"))

        let encoded = try JSONEncoder().encode(config)

        #expect(String(decoding: encoded, as: UTF8.self) == #"{"domain":"example.com"}"#)
        #expect(try JSONDecoder().decode(Config.self, from: encoded) == config)
    }

    @Test
    func `a malformed domain fails to decode`() throws {
        let encoded = Data(#""invalid domain with spaces""#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Domain.self, from: encoded)
        }
    }
}
