public import RFC_1035
public import RFC_1123

public struct Domain: Hashable, Sendable {

    public let rfc1035: RFC_1035.Domain?

    public let rfc1123: RFC_1123.Domain

    public init(rfc1035: RFC_1035.Domain) throws(Error) {
        self.rfc1035 = rfc1035

        do throws(RFC_1123.Domain.Error) {
            self.rfc1123 = try RFC_1123.Domain(rfc1035.name)
        } catch {
            throw Error.conversionFailure("RFC 1035", to: "RFC 1123")
        }
    }

    public init(rfc1123: RFC_1123.Domain) {

        do throws(RFC_1035.Domain.Error) {
            self.rfc1035 = try RFC_1035.Domain(rfc1123.name)
        } catch {
            self.rfc1035 = nil
        }
        self.rfc1123 = rfc1123
    }
}

extension Domain {

    public init<S: StringProtocol>(_ string: S) throws(Error) {

        let rfc1123: RFC_1123.Domain
        do throws(RFC_1123.Domain.Error) {
            rfc1123 = try RFC_1123.Domain(String(string))
        } catch {
            throw Error.invalidFormat(String(string))
        }

        self.init(rfc1123: rfc1123)
    }

    public init<S: StringProtocol>(labels: [S]) throws(Error) {
        try self.init(labels.map { String($0) }.joined(separator: "."))
    }
}

extension Domain {

    public var name: String {
        rfc1035?.name ?? rfc1123.name
    }

    public var tld: String? {
        rfc1035?.tld?.rawValue ?? rfc1123.tld?.rawValue
    }

    public var sld: String? {
        rfc1035?.sld?.rawValue ?? rfc1123.sld?.rawValue
    }

    public var isRFC1035Compliant: Bool {
        rfc1035 != nil
    }

    public var isStandardDomain: Bool {
        true
    }
}

extension Domain {

    public func isSubdomain(of parent: Domain) -> Bool {

        if let myRFC1035 = rfc1035, let parentRFC1035 = parent.rfc1035 {
            return myRFC1035.isSubdomain(of: parentRFC1035)
        }
        return rfc1123.isSubdomain(of: parent.rfc1123)
    }

    public func addingSubdomain<S: StringProtocol>(_ components: S...) throws(Error) -> Domain {
        let stringComponents = components.map { String($0) }

        if let domain = rfc1035 {
            do {
                return try Domain(rfc1035: domain.addingSubdomain(stringComponents))
            } catch {
                throw Error.cannotCreateSubdomain
            }
        }

        do throws(RFC_1123.Domain.Error) {
            let subdomain = try rfc1123.addingSubdomain(stringComponents)
            return Domain(rfc1123: subdomain)
        } catch {
            throw Error.cannotCreateSubdomain
        }
    }

    public func parent() throws(Error) -> Domain? {

        if let domain = rfc1035 {
            do {
                guard let parent = try domain.parent() else { return nil }
                return try Domain(rfc1035: parent)
            } catch {
                throw Error.conversionFailure("RFC 1035", to: "parent domain")
            }
        }

        guard let parent = rfc1123.parent() else { return nil }
        return Domain(rfc1123: parent)
    }

    public func root() throws(Error) -> Domain? {
        if let domain = rfc1035 {
            do {
                guard let root = try domain.root() else { return nil }
                return try Domain(rfc1035: root)
            } catch {
                throw Error.conversionFailure("RFC 1035", to: "root domain")
            }
        }

        guard let root = rfc1123.root() else { return nil }
        return Domain(rfc1123: root)
    }
}

extension Domain {

    public enum Error: Swift.Error, Equatable {

        case invalidFormat(_ description: String)

        case cannotCreateSubdomain

        case conversionFailure(_ from: String, to: String)

        case idnaConversionFailure(_ reason: String)
    }
}

extension Domain.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidFormat(let desc):
            return "Invalid domain format: \(desc)"

        case .cannotCreateSubdomain:
            return "Cannot create subdomain for this domain type"

        case .conversionFailure(let from, let to):
            return "Failed to convert from \(from) to \(to)"

        case .idnaConversionFailure(let reason):
            return "IDNA conversion failed: \(reason)"
        }
    }
}

extension Domain: CustomStringConvertible {
    public var description: String { name }
}

extension Domain: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }
}

extension Domain: RawRepresentable {
    public var rawValue: String { name }
    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
    }
}
