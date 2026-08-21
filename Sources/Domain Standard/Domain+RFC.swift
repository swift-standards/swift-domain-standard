public import RFC_1035
public import RFC_1123

extension RFC_1035.Domain {

    public init(_ domain: Domain) throws(RFC_1035.Domain.Error) {
        if let rfc1035 = domain.rfc1035 {
            self = rfc1035
        } else {

            try self.init(domain.name)
        }
    }
}

extension RFC_1123.Domain {

    public init(_ domain: Domain) {
        self = domain.rfc1123
    }
}
