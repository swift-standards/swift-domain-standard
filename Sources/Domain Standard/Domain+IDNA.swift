import RFC_5890

extension Domain {

    public init(ascii domain: Domain) throws(Error) {
        let asciiString: String
        do throws(IDNA.Error) {
            asciiString = try IDNA.toASCII(domain.name)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to ASCII: \(error.description)"
            )
        }
        try self.init(asciiString)
    }

    public init(unicode domain: Domain) throws(Error) {
        let unicodeString: String
        do throws(IDNA.Error) {
            unicodeString = try IDNA.toUnicode(domain.name)
        } catch {
            throw Error.idnaConversionFailure(
                "Failed to convert '\(domain.name)' to Unicode: \(error.description)"
            )
        }
        try self.init(unicodeString)
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
