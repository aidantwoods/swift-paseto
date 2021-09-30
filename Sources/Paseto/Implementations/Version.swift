//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

public enum Version: String {
    case v1 = "v1"
    case v2 = "v2"
    case v3 = "v3"
}

extension Version {
    init <M: Module>(module: M.Type) {
        switch module {
        case is Version1.Local.Type: self = .v1
        case is Version2.Local.Type: self = .v2
        case is Version2.Public.Type: self = .v2
        case is Version3.Local.Type: self = .v3
        default: fatalError("All implementations must be enumerated")
        }
    }
}
