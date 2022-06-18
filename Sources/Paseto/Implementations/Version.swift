public enum Version: String {
    case v1 = "v1"
    case v2 = "v2"
    case v3 = "v3"
    case v4 = "v4"
}

extension Version {
    init <M: Module>(module: M.Type) {
        if #available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *) {
            switch module {
            case is Version1.Local.Type: self = .v1
            case is Version2.Local.Type: self = .v2
            case is Version2.Public.Type: self = .v2
            case is Version3.Local.Type: self = .v3
            case is Version3.Public.Type: self = .v3
            case is Version4.Local.Type: self = .v4
            case is Version4.Public.Type: self = .v4
            default: fatalError("All implementations must be enumerated")
            }
        } else {
            switch module {
            case is Version1.Local.Type: self = .v1
            case is Version2.Local.Type: self = .v2
            case is Version2.Public.Type: self = .v2
            case is Version3.Local.Type: self = .v3
            case is Version4.Local.Type: self = .v4
            case is Version4.Public.Type: self = .v4
            default: fatalError("All implementations must be enumerated")
            }
        }
    }
}
