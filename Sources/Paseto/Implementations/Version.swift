//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

public enum Version: String {
    case v1 = "v1"
    case v2 = "v2"
}

extension Version {
    init <I: Implementation>(implementation: I.Type) {
        switch implementation {
        case is Version1.Type: self = .v1
        case is Version2.Type: self = .v2
        default: fatalError("All implementations must be enumerated")
        }
    }
}
