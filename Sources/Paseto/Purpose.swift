public enum Purpose: String {
    case Local  = "local"
    case Public = "public"
}

extension Purpose {
    init <P: Payload>(payload: P.Type) {
        if #available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *) {
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
