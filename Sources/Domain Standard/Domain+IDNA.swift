import RFC_5890

extension Domain {

    public init(ascii domain: Domain) throws(Error) {
        do {
            let asciiString = try IDNA.toASCII(domain.name)
            try self.init(asciiString)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to ASCII: \(error)"
            )
        }
    }

    public init(unicode domain: Domain) throws(Error) {
        do {
            let unicodeString = try IDNA.toUnicode(domain.name)
            try self.init(unicodeString)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to Unicode: \(error)"
            )
        }
    }
}

extension Domain {

    public var isInternationalized: Bool {
        !name.allSatisfy({ $0.isASCII })
    }

    public var hasALabels: Bool {
        name.split(separator: ".").contains { IDNA.isALabel(String($0)) }
    }

    public var isASCII: Bool {
        name.allSatisfy({ $0.isASCII })
    }
}
