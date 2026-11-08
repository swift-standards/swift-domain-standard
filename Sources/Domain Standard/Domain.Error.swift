import RFC_1035
import RFC_1123

extension Domain {
    public enum Error: Swift::Error, Equatable {

        case invalidFormat(_ description: String)

        case cannotCreateSubdomain

        case conversionFailure(_ from: String, to: String)

        case idnaConversionFailure(_ reason: String)
    }
}
