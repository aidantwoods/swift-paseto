public enum Purpose: String {
    case Local  = "local"
    case Public = "public"
}

extension Purpose {
    init <P: Payload>(payload: P.Type) {
        if #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *) {
            switch payload {
            case is Version1.Local.Payload.Type: self = .Local
            case is Version2.Local.Payload.Type: self = .Local
            case is Version2.Public.Payload.Type: self = .Public
            case is Version3.Local.Payload.Type: self = .Local
            case is Version3.Public.Payload.Type: self = .Public
            case is Version4.Local.Payload.Type: self = .Local
            case is Version4.Public.Payload.Type: self = .Public
            default: fatalError("All implementations must be enumerated")
            }
        } else {
            switch payload {
            case is Version1.Local.Payload.Type: self = .Local
            case is Version2.Local.Payload.Type: self = .Local
            case is Version2.Public.Payload.Type: self = .Public
            case is Version3.Local.Payload.Type: self = .Local
            case is Version4.Local.Payload.Type: self = .Local
            case is Version4.Public.Payload.Type: self = .Public
            default: fatalError("All implementations must be enumerated")
            }
        }
    }
}
